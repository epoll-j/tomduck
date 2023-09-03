//
//  ExchangeHandler.swift
//  Runner
//
//  Created by Dubhe on 2023/8/15.
//

import Foundation
import NIO
import NIOHTTP1
import NIOFoundationCompat

class ExchangeHandler: ChannelInboundHandler, RemovableChannelHandler {
    typealias InboundIn = HTTPClientResponsePart
    typealias OutboundOut = HTTPServerResponsePart
    
    var proxyContext: ProxyContext
    var gotEnd: Bool = false
    init(proxyContext: ProxyContext) {
        self.proxyContext = proxyContext
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let res = self.unwrapInboundIn(data)
        switch res {
        case .head(let head):
            _ = proxyContext.serverChannel?.writeAndFlush(HTTPServerResponsePart.head(head))
        case .body(let body):
            if body.readableBytes > 1024 * 1024 {
                print("超大：\(body.readableBytes)")
            }
            _ = proxyContext.serverChannel?.writeAndFlush(HTTPServerResponsePart.body(.byteBuffer(body)))
        case .end(let tailHeaders):
            gotEnd = true
            let promise = proxyContext.serverChannel?.eventLoop.makePromise(of: Void.self)
            proxyContext.serverChannel?.writeAndFlush(HTTPServerResponsePart.end(tailHeaders), promise: promise)
            promise?.futureResult.whenComplete({ (_) in
                if self.proxyContext.serverChannel!.isActive {
                    self.proxyContext.serverChannel!.close(mode: .all, promise: nil)
                }
            })
            let outPromise = context.eventLoop.makePromise(of: Void.self)
            context.channel.close(mode: .all, promise: outPromise)
            outPromise.futureResult.whenComplete { (_) in
            }
            return
        }
        context.fireChannelRead(data)
        
    }
    
    func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }
    
    func channelUnregistered(context: ChannelHandlerContext) {
        context.close(mode: .all, promise: nil)
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        if let channelError = error as? ChannelPipelineError {
            if channelError == .notFound && proxyContext.request!.ssl {
                return
            }
        }
        
        context.channel.close(mode: .all,promise: nil)

        if proxyContext.serverChannel!.isActive {
            _ = self.proxyContext.serverChannel!.close(mode: .all)
        }
    }
    
    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {

    }
}
