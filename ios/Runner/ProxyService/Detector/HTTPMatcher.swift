//
//  HttpMatcher.swift
//  Runner
//
//  Created by Dubhe on 2023/8/16.
//

import UIKit
import NIO
import NIOHTTP1

class HTTPMatcher: Matcher {
    
    private let methods:Set<String> = ["GET", "POST", "PUT", "HEAD", "OPTIONS", "PATCH", "DELETE","TRACE"]
    
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
        let strArray = front8.components(separatedBy: " ")
        if strArray.count <= 0 {
            return Matcher.MISMATCH
        }
        if methods.contains(strArray.first!) {
            return Matcher.MATCH
        }
        return Matcher.MISMATCH
    }
    
    override func handlePipeline(pipleline: ChannelPipeline, task: Task) {
        let pc = ProxyContext(isHttp: true, task: task)
        _ = pipleline.configureHTTPServerPipeline()
        _ = pipleline.addHandler(HTTPHandler(proxyContext: pc), name: "HTTPHandle", position: .last)
    }
    
}
