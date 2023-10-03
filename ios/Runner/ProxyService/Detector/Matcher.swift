//
//  Matcher.swift
//  Runner
//
//  Created by Dubhe on 2023/8/13.
//

import NIO

class Matcher {
    
    static let MATCH = 1
    static let MISMATCH = -1
    static let PENDING = 0
    
    public func match(buf: ByteBuffer) -> Int {return -1}
    
    public func handlePipeline(pipleline: ChannelPipeline, task: Task) -> Void {}
    
}
