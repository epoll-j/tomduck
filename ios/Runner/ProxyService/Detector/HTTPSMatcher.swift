//
//  HTTPSMatcher.swift
//  Runner
//
//  Created by Dubhe on 2023/8/20.
//

import Foundation
import NIO
import NIOHTTP1
import Foundation

class HTTPSMatcher: Matcher {
    
    public override init() {
        super.init()
        
    }
    
    override func match(buf: ByteBuffer) -> Int {
        
        if buf.readableBytes < 8 {
            return Matcher.PENDING
        }
        
        guard let front8 = buf.getString(at: 0, length: 8) else {
            return Matcher.MISMATCH
        }
        if "CONNECT " == front8 {
            return Matcher.MATCH
        }
        return Matcher.MISMATCH
    }
    
    override func handlePipeline(pipleline: ChannelPipeline, task: Task) {
        let pc = ProxyContext(isHttp:true, task:task)
//        pc.session.schemes = "Https"
        _ = pipleline.addHandler(HTTPResponseEncoder(), name: "HTTPResponseEncoder", position: .last)
        let requestDecoder = HTTPRequestDecoder(leftOverBytesStrategy: .dropBytes)
        _ = pipleline.addHandler(ByteToMessageHandler(requestDecoder), name: "ByteToMessageHandler", position: .last)
        _ = pipleline.addHandler(HTTPServerPipelineHandler(), name: "HTTPServerPipelineHandler", position: .last)
        _ = pipleline.addHandler(HTTPSHandler(proxyContext: pc), name: "HTTPSHandler", position: .last)
    }
}
