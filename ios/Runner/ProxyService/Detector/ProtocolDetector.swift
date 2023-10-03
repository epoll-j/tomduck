//
//  ProtocolDetector.swift
//  Runner
//
//  Created by Dubhe on 2023/8/13.
//

import UIKit
import NIO
import NIOHTTP1

public final class ProtocolDetector: ChannelInboundHandler, RemovableChannelHandler {
    public typealias InboundIn =  ByteBuffer
    public typealias InboundOut = ByteBuffer
    
    private var buf:ByteBuffer?
    
    private var index:Int = 0 //

    private let matcherList: [Matcher]
    public var task: Task
    
    init(task: Task ,matchers: [Matcher]) {
        self.matcherList = matchers
        self.task = task
    }
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        if let local = context.channel.localAddress?.description {
            let isLocal = local.contains("127.0.0.1")
            if (isLocal && task.localEnable == 0) || (!isLocal && task.wifiEnable == 0) {
                context.flush()
                context.close(promise: nil)

                return
            }
        }
        let buffer = unwrapInboundIn(data)
        //TODO: 需要处理粘包情况以及数据不完整情况
        for i in index..<matcherList.count {
            let matcher = matcherList[i]
            let match = matcher.match(buf: buffer)
            if match == Matcher.MATCH {
                matcher.handlePipeline(pipleline: context.pipeline, task: task)
                context.fireChannelRead(data)
                context.pipeline.removeHandler(self, promise: nil)
                return
            }
            if match == Matcher.PENDING {
                index = i
                return
            }
        }
        // all miss
        context.flush()
        context.close(promise: nil)
        print("unsupported protocol")
    }
    
    public func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        print("userInboundEventTriggered:\(event)")
//        context.channel.
    }
    
    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("ProtocolDetector error: \(error.localizedDescription)")
        context.close(promise: nil)
    }
    
    private func startReading(context: ChannelHandlerContext) {
        print("startReading")
    }
    
    private func deliverPendingRequests(context: ChannelHandlerContext) {
        print("deliverPendingRequests")
    }
    
}
