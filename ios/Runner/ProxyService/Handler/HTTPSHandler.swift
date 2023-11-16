//
//  HTTPSHandler.swift
//  Runner
//
//  Created by Dubhe on 2023/8/20.
//

import Foundation
import NIOHTTP1
import NIO

class HTTPSHandler: ChannelInboundHandler, RemovableChannelHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart//IOData//
    
    enum ResponseState {
        case ready
        case parsingBody(HTTPRequestHead, ByteBuffer?)
    }
    
    var state: ResponseState
    var proxyContext: ProxyContext
    
    init(proxyContext: ProxyContext) {
        self.state = .ready
        self.proxyContext = proxyContext
    }
    
    // 原始消息报文
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        prepareProxyContext(context: context, data: data)
        let res = self.unwrapInboundIn(data)
        switch res {
        case .head(let head):
            switch self.state {
            case .ready: self.state = .parsingBody(head, nil)
            case .parsingBody: assert(false, "Unexpected HTTPServerRequestPart.head when body was being parsed.")
            }
        case .body(var body):
            switch self.state {
            case .ready: assert(false, "Unexpected HTTPServerRequestPart.body when awaiting request head.")
            case .parsingBody(let head, let existingData):
                let buffer: ByteBuffer
                if var existing = existingData {
                    existing.writeBuffer(&body)
                    buffer = existing
                } else {
                    buffer = body
                }
                self.state = .parsingBody(head, buffer)
            }
        case .end(let tailHeaders):
            assert(tailHeaders == nil, "Unexpected tail headers")
            switch self.state {
            case .ready: assert(false, "Unexpected HTTPServerRequestPart.end when awaiting request head.")
            case .parsingBody(var head, _):
                let req = ProxyRequest(head)
                // 移除代理相关头
                head.headers = ProxyRequest.removeProxyHead(heads: head.headers)
                // 填充数据到session
                proxyContext.session.request_line = "\(head.method) \(head.uri) \(head.version)"
                proxyContext.session.host = req.host
                proxyContext.session.local_address = Session.getIPAddress(socketAddress: context.channel.remoteAddress)
                proxyContext.session.methods = "\(head.method)"
                proxyContext.session.uri = head.uri
                proxyContext.session.request_http_version = "\(head.version)"
                proxyContext.session.target = Session.getUserAgent(target: head.headers["User-Agent"].first)
                proxyContext.session.request_header = Session.getHeadsJson(headers: head.headers)
                proxyContext.session.connect_time = NSNumber(value: Date().timeIntervalSince1970)// 开始建立连接
                
                
                // 必须加个content-length:0 不然会自动添加transfer-encoding:chunked,导致部分设备无法识别，坑
                let rspHead = HTTPResponseHead(version: head.version,
                                               status: .custom(code: 200, reasonPhrase: "Connection Established"),
                                               headers: ["content-length":"0"])
                context.channel.writeAndFlush(HTTPServerResponsePart.head(rspHead), promise: nil)
                context.channel.writeAndFlush(HTTPServerResponsePart.end(nil), promise: nil)
                // 移除多余handler
                context.pipeline.removeHandler(name: "ProtocolDetector", promise: nil)
                context.pipeline.removeHandler(name: "HTTPResponseEncoder", promise: nil)
                context.pipeline.removeHandler(name: "ByteToMessageHandler", promise: nil)
                context.pipeline.removeHandler(name: "HTTPServerPipelineHandler", promise: nil)
                context.pipeline.removeHandler(name: "HTTPSHandler", promise: nil)
                // 添加ssl握手处理handler
                let cancelTask = context.channel.eventLoop.scheduleTask(in:  TimeAmount.seconds(10)) {
                    self.proxyContext.session.note = "error:can not get client hello from APP \(self.proxyContext.session.target ?? "")"
                    self.proxyContext.session.state = -1
                    context.channel.close(mode: .all,promise: nil)
                }

                if !proxyContext.session.ignore {
                    _ = context.pipeline.addHandler(SSLHandler(proxyContext: proxyContext, scheduled: cancelTask), name: "SSLHandler", position: .first)
                } else {
                    _ = context.pipeline.addHandler(TunnelProxyHandler(proxyContext: proxyContext, isOut: false,scheduled:cancelTask), name: "TunnelProxyHandler", position: .first)
                }
                return
            }
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
                proxyContext.request?.ssl = true
                proxyContext.session.ignore = proxyContext.task.rule.matchFilter(head.uri)
            }
        case .body(_),.end(_):
            break
        }
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
//        print("HTTPSHandler errorCaught:\(error.localizedDescription)")
//        _ = context.channel.close(mode: .all)
        proxyContext.serverChannel?.close(mode: .all, promise: nil)
        if let cc = proxyContext.clientChannel ,cc.isActive {
            _ = cc.close(mode: .all)
        }
    }
}
