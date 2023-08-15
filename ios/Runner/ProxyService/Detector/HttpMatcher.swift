//
//  HttpMatcher.swift
//  Runner
//
//  Created by Dubhe on 2023/8/16.
//

import UIKit
import NIO
import NIOHTTP1

class HttpMatcher: Matcher {
    
    private let methods:Set<String> = ["GET", "POST", "PUT", "HEAD", "OPTIONS", "PATCH", "DELETE","TRACE"]
    
    public override init() {
        super.init()
        
    }
    
    override func match(buf: ByteBuffer) -> Int {
        if buf.readableBytes < 8 {
            return ProtocolMatcher.PENDING
        }
        
        guard let front8 = buf.getString(at: 0, length: 8) else {
            return ProtocolMatcher.MISMATCH
        }
        let strArray = front8.components(separatedBy: " ")
        if strArray.count <= 0 {
            return ProtocolMatcher.MISMATCH
        }
        if methods.contains(strArray.first!) {
            return ProtocolMatcher.MATCH
        }
        return ProtocolMatcher.MISMATCH
    }
    
    override func handlePipeline(pipleline: ChannelPipeline, task: CaughtTask) {
        let pc = ProxyContext(isHttp: true, task: task)
        pc.session.schemes = "Http"
        _ = pipleline.configureHTTPServerPipeline()
        _ = pipleline.addHandler(HTTPHandler(proxyContext: pc), name: "HTTPHandle", position: .last)
    }
    
}
