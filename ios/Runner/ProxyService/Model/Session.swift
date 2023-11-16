//
//  Session.swift
//  Runner
//
//  Created by dubhe on 2023/10/8.
//

import Foundation
import NIOCore
import NIOHTTP1

public class Session {
    public var id: NSNumber?
    public var task_id: NSNumber!
    public var remote_address: String?
    public var local_address: String?
    public var host: String?
    public var schemes: String?
    public var request_line: String?
    public var methods: String?
    public var uri: String?
    public var suffix: String?
    
    public var request_content_type: String?
    public var request_content_encoding: String?
    public var request_header: String?
    public var request_http_version: String?
    public var request_body: String?
    
    public var target: String?
    public var http_code: String?
    
    public var response_content_type: String?
    public var response_content_encoding: String?
    public var response_header: String?
    public var response_http_version: String?
    public var response_body: String?
    public var response_msg: String?
    
    public var start_time: NSNumber?
    public var connect_time: NSNumber?
    public var connected_time: NSNumber?
    public var handshake_time: NSNumber?
    public var request_end_time: NSNumber?
    public var response_start_time: NSNumber?
    public var response_end_time: NSNumber?
    public var end_time: NSNumber?
            
    public var upload_flow: NSNumber = 0
    public var download_flow: NSNumber = 0
    
    public var state: NSNumber = 1
    public var note: String?
    
    public var ignore = false
    
    public let random = arc4random()
    
    public static func newSession(_ task: Task) -> Session {
        let session = Session()
        session.task_id = task.id
        session.start_time = NSNumber(value: Date().timeIntervalSince1970)
        return session
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(setId), name: NSNotification.Name(rawValue: "setId_\(self.random)"), object: nil)
    }
    
    @objc private func setId(_ notify: NSNotification) {
        if let id = notify.object as? Int {
            self.id = NSNumber(value: id)
        }
    }
    
    public func save() {
        if self.ignore {
            return
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "save_session"), object: JSONSerializer.toJson(self))
        }
    }
    
    public func writeBody() {
        if self.ignore {
            return
        }
    }
    
    static func getIPAddress(socketAddress: SocketAddress?) -> String {
        if let address = socketAddress?.description {
            let array = address.components(separatedBy: "/")
            return array.last ?? address
        } else {
            return "unknow"
        }
    }
    
    static func getUserAgent(target: String?) -> String {
        if target != nil {
            let firstTarget = target!.components(separatedBy: " ").first
            return firstTarget?.components(separatedBy: "/").first ?? target!
        }
        return ""
    }
    
    static func getHeadsJson(headers: HTTPHeaders) -> String {
        var reqHeads = [String: String]()
        for kv in headers {
            reqHeads[kv.name] = kv.value
        }
        return reqHeads.toJson()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
