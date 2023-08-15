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

class HTTPHandler : ChannelInboundHandler, RemovableChannelHandler {
    
    typealias InboundIn = HTTPServerRequestPart
    
    var connected: Bool
    var proxyContext: ProxyContext
    var requestDatas = [Any]()
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
            
            let uri = head.uri
            if !uri.starts(with: "/"),let hostStr = head.headers["Host"].first {
                if let newUri = uri.components(separatedBy: hostStr).last {
                    head.uri = newUri
                }
            }
            handleData(head)
            break
        case .body(let body):
            handleData(body)
            break
        case .end(let end):
            handleData(end, isEnd: true)
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
        if request.ssl {
            // TODO:添加握手超时断开
            channelInitializer = { (outChannel) -> EventLoopFuture<Void> in
                self.proxyContext.clientChannel = outChannel
                var tlsClientConfiguration = TLSConfiguration.makeClientConfiguration()
                tlsClientConfiguration.applicationProtocols = ["http/1.1"]
                let sslClientContext = try! NIOSSLContext(configuration: tlsClientConfiguration)
                
                let sniName = request.host.isIP() ? nil : request.host
                
                let sslClientHandler = try! NIOSSLClientHandler(context: sslClientContext, serverHostname: sniName)
                let applicationProtocolNegotiationHandler = ApplicationProtocolNegotiationHandler { (result) -> EventLoopFuture<Void> in
                    self.connected = true
                    return outChannel.pipeline.addHandler(HTTPRequestEncoder(), name: "HTTPRequestEncoder").flatMap({
                        outChannel.pipeline.addHandler(ByteToMessageHandler(HTTPResponseDecoder()), name: "ByteToMessageHandler").flatMap({
                            outChannel.pipeline.addHandler(ExchangeHandler(proxyContext: self.proxyContext), name: "ExchangeHandler").flatMap({
                                //HTTPS发送请求时间
                                self.handleData(nil)
                                return outChannel.pipeline.removeHandler(name: "xxxxxxxxxxxxx")
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
        cf = clientBootstrap.connect(host: request.host, port: request.port)
        cf!.whenComplete { result in
            switch result {
            case .success(let outChannel):
                self.proxyContext.clientChannel = outChannel
                if !request.ssl {
                    self.connected = true
                    self.handleData(nil)
                }
                break
            case .failure(let error):
                print("outChannel connect failure:\(error)")
                _ = self.proxyContext.serverChannel?.close()
                _ = self.proxyContext.clientChannel?.close()
                break
            }
        }
    }
    
    func sendData(data:Any) {
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
            })
        }
        if let endstr = data as? String, endstr == "end" {
            let promise = proxyContext.clientChannel?.eventLoop.makePromise(of: Void.self)
            proxyContext.clientChannel!.writeAndFlush(HTTPClientRequestPart.end(nil), promise: promise)
            promise?.futureResult.whenComplete({ (_) in
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
}
