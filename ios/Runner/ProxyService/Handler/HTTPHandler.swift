//
//  HttpHandler.swift
//  Runner
//
//  Created by Dubhe on 2023/8/15.
//

import Foundation
import NIO
import NIOTLS
import NIOHTTP1
import NIOConcurrencyHelpers
import NIOSSL
import Network
import SwiftyJSON

class HTTPHandler : ChannelInboundHandler, RemovableChannelHandler {
    
    typealias InboundIn = HTTPServerRequestPart
    
    var connected: Bool
    var proxyContext: ProxyContext
    var requestDatas = [Any]()
    var isSendBody = false
    var cf: EventLoopFuture<Channel>?
    
    init(proxyContext: ProxyContext) {
        self.connected = false
        self.proxyContext = proxyContext
    }

    // 原始消息报文
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        prepareProxyContext(context: context, data: data)
        if cf == nil {
            connectToServer()// 1、建立连接
        }
        let res = self.unwrapInboundIn(data)
        switch res {
        case .head(var head):
            head.headers = ProxyRequest.removeProxyHead(heads: head.headers)
            // 记录请求头到数据库
            proxyContext.session.request_line = "\(head.method) \(head.uri) \(head.version)"
            proxyContext.session.host = head.headers["Host"].first ?? proxyContext.request?.host
            proxyContext.session.local_address = Session.getIPAddress(socketAddress: context.channel.remoteAddress)
            proxyContext.session.methods = "\(head.method)"
            proxyContext.session.uri = head.uri
            proxyContext.session.request_http_version = "\(head.version)"
            proxyContext.session.target = Session.getUserAgent(target: head.headers["User-Agent"].first)
            proxyContext.session.request_header = Session.getHeadsJson(headers: head.headers)
            proxyContext.session.request_content_encoding = head.headers["Content-Encoding"].first ?? ""
            proxyContext.session.request_content_type = head.headers["Content-Type"].first ?? ""
            
            proxyContext.session.save()
            
            handleData(proxyContext.replace(head))
            break
        case .body(let body):
            proxyContext.session.writeBody(type: .Request, buffer: body)
            let reqBody = proxyContext.task.rule.getFalsify(ignore: proxyContext.session.ignore, request: proxyContext.request!, type: 0, key: "req_body")
            if reqBody != nil {
                if (!isSendBody) {
                    isSendBody = true
                    for buff in reqBody!.stringValue.toByteBuffer() {
                        handleData(buff)
                    }
                }
            } else {
                handleData(body)
            }
            break
        case .end(let end):
            handleData(end, isEnd: true)
            proxyContext.session.writeBody(type: .Request, buffer: nil)
            break
        }
        context.fireChannelRead(data)
    }
    
    func connectToServer() -> Void {
        guard let request = proxyContext.request else {
            print("no request ! --> end")
            _ = proxyContext.serverChannel?.close(mode: .all)
            return
        }
        var channelInitializer: ((Channel) -> EventLoopFuture<Void>)?
        let connectHost = proxyContext.task.rule.redirect(ignore: proxyContext.session.ignore, request: request)
        if request.ssl {
            // TODO:添加握手超时断开
            channelInitializer = { (outChannel) -> EventLoopFuture<Void> in
                self.proxyContext.clientChannel = outChannel
                var tlsClientConfiguration = TLSConfiguration.makeClientConfiguration()
                tlsClientConfiguration.applicationProtocols = ["http/1.1"]
                let sslClientContext = try! NIOSSLContext(configuration: tlsClientConfiguration)
                
                let sslClientHandler = try! NIOSSLClientHandler(context: sslClientContext, serverHostname: connectHost.0.isIP() ? nil : connectHost.0)
                let applicationProtocolNegotiationHandler = ApplicationProtocolNegotiationHandler { (result) -> EventLoopFuture<Void> in
                    self.connected = true
                    self.proxyContext.session.handshake_time = NSNumber(value: Date().timeIntervalSince1970) //握手结束时间
                    return outChannel.pipeline.addHandler(HTTPRequestEncoder(), name: "HTTPRequestEncoder").flatMap({
                        outChannel.pipeline.addHandler(ByteToMessageHandler(HTTPResponseDecoder()), name: "ByteToMessageHandler").flatMap({
                            outChannel.pipeline.addHandler(ExchangeHandler(proxyContext: self.proxyContext), name: "ExchangeHandler").flatMap({
                                //HTTPS发送请求时间
                                self.handleData(nil)
                                return outChannel.pipeline.removeHandler(name: "none")
                            })
                        })
                    })
                }
                _ = outChannel.pipeline.addHandler(ChannelWatchHandler(proxyContext: self.proxyContext), name: "ChannelWatchHandler")
                return outChannel.pipeline.addHandler(sslClientHandler, name: "NIOSSLClientHandler").flatMap({
                    outChannel.pipeline.addHandler(applicationProtocolNegotiationHandler, name: "ApplicationProtocolNegotiationHandler")
                })
            }
        } else {
            proxyContext.session.connect_time = NSNumber(value: Date().timeIntervalSince1970)
            channelInitializer = { (outChannel) -> EventLoopFuture<Void> in
                self.proxyContext.clientChannel = outChannel
                _ = outChannel.pipeline.addHandler(ChannelWatchHandler(proxyContext: self.proxyContext), name: "ChannelWatchHandler")
                return outChannel.pipeline.addHTTPClientHandlers().flatMap({
                    outChannel.pipeline.addHandler(ExchangeHandler(proxyContext: self.proxyContext), name: "ExchangeHandler")
                })
            }
        }
        
        let clientBootstrap = ClientBootstrap(group: proxyContext.serverChannel!.eventLoop.next())//SO_SNDTIMEO
            .channelInitializer(channelInitializer!)
        cf = clientBootstrap.connect(host: connectHost.0, port: connectHost.1)
        cf!.whenComplete { result in
            switch result {
            case .success(let outChannel):
                self.proxyContext.session.connected_time = NSNumber(value: Date().timeIntervalSince1970)  // 建立连接成功
                self.proxyContext.session.remote_address = Session.getIPAddress(socketAddress: outChannel.remoteAddress)
                self.proxyContext.clientChannel = outChannel
                if !request.ssl {
                    self.connected = true
                    self.handleData(nil)
                }
                self.proxyContext.session.save()
                break
            case .failure(let error):
                print("outChannel connect failure:\(error)")
                _ = self.proxyContext.serverChannel?.close()
                _ = self.proxyContext.clientChannel?.close()
                self.proxyContext.session.note = "error:connect \(request.host):\(request.port) failure:\(error)!"
                break
            }
        }
    }
    
    func sendData(data: Any) {
        if let head = data as? HTTPRequestHead {
            let clientHead = HTTPRequestHead(version: head.version, method: head.method, uri: head.uri, headers: head.headers)
            _ = proxyContext.clientChannel!.writeAndFlush(HTTPClientRequestPart.head(clientHead))
        }
        if let body = data as? ByteBuffer{
            _ = proxyContext.clientChannel!.writeAndFlush(HTTPClientRequestPart.body(.byteBuffer(body)))
        }
        if let end = data as? HTTPHeaders {
            let promise = proxyContext.clientChannel?.eventLoop.makePromise(of: Void.self)
            proxyContext.clientChannel!.writeAndFlush(HTTPClientRequestPart.end(end), promise: promise)
            promise?.futureResult.whenComplete({ (_) in
                self.proxyContext.session.request_end_time = NSNumber(value: Date().timeIntervalSince1970)
                self.proxyContext.session.save()
            })
        }
        if let endstr = data as? String, endstr == "end" {
            let promise = proxyContext.clientChannel?.eventLoop.makePromise(of: Void.self)
            proxyContext.clientChannel!.writeAndFlush(HTTPClientRequestPart.end(nil), promise: promise)
            promise?.futureResult.whenComplete({ (_) in
                self.proxyContext.session.request_end_time = NSNumber(value: Date().timeIntervalSince1970)
                self.proxyContext.session.save()
            })
        }
    }
    
    func handleData(_ data: Any?, isEnd: Bool = false) -> Void {
        if connected,let outChannel = proxyContext.clientChannel,outChannel.isActive {
            for rd in requestDatas{
                sendData(data: rd)
            }
            if data != nil {
                sendData(data: data!)
            }
            if data == nil, isEnd {
                sendData(data: "end")
            }
            requestDatas.removeAll()
        } else {
            guard let msg = data else {
                if isEnd {
                    requestDatas.append("end")
                }
                return
            }
            requestDatas.append(msg)
        }
    }
    
    func prepareProxyContext(context: ChannelHandlerContext, data: NIOAny) -> Void {
        if proxyContext.serverChannel == nil {
            proxyContext.serverChannel = context.channel
        }
        let res = self.unwrapInboundIn(data)
        switch res {
        case .head(let head):
            if proxyContext.request == nil {
                proxyContext.request = ProxyRequest(head)
                if !proxyContext.request!.ssl {
                    proxyContext.session.ignore = proxyContext.task.rule.matchFilter(head.uri)
                }
            }
        case .body(_),.end(_):
            break
        }
    }
    
    func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }
    
    func channelUnregistered(context: ChannelHandlerContext) {
        context.close(mode: .all, promise: nil)
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        context.close(mode: .all, promise: nil)
        proxyContext.clientChannel?.close(mode: .all, promise: nil)
        context.fireErrorCaught(error)
    }
    
    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
    }
    
    private func _getHeader(origin: HTTPRequestHead) -> HTTPRequestHead {
        return origin
    }
}
