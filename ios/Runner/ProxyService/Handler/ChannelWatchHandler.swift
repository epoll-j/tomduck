//
//  ChannelWatchHandler.swift
//  Runner
//
//  Created by Dubhe on 2023/8/15.
//

import Foundation
import NIO

class ChannelWatchHandler: ChannelDuplexHandler, RemovableChannelHandler {
    
    typealias InboundIn = ByteBuffer
    typealias OutboundIn = ByteBuffer
    
    
    var proxyContext: ProxyContext
    
    init(proxyContext: ProxyContext) {
        self.proxyContext = proxyContext
    }
    
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let outData = unwrapInboundIn(data)
        let sum = self.proxyContext.session.upload_flow
        self.proxyContext.session.upload_flow = NSNumber(value: (sum.intValue + outData.readableBytes))
        context.writeAndFlush(data, promise: promise)
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let inData = unwrapInboundIn(data)
        let sum = self.proxyContext.session.download_flow
        self.proxyContext.session.download_flow = NSNumber(value: (sum.intValue + inData.readableBytes))
        context.fireChannelRead(data)
    }
    
}
