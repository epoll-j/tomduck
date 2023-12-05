//
//  ProxyContext.swift
//  Runner
//
//  Created by Dubhe on 2023/8/15.
//

import UIKit
import NIO
import NIOHTTP1

class ProxyContext: NSObject {
    
    var _clientChannel: Channel?
    var clientChannel: Channel? {
        set {
            _clientChannel = newValue
            _clientChannel?.closeFuture.whenComplete({ (R) in
                switch R {
                case .failure(let error):
                    print("******\(self.request?.host ?? "") clientChannel close error ! \(error.localizedDescription)")
                    break
                case .success(_):
                    self.session.end_time = NSNumber(value: Date().timeIntervalSince1970)
                    self.session.save()
                    self.serverChannel?.close(mode: .all, promise: nil)
                    break
                }
            })
        }
        get {
            return _clientChannel
        }
    }
    
    var _serverChannel: Channel?
    var serverChannel: Channel? {
        set {
            _serverChannel = newValue
            _serverChannel?.closeFuture.whenComplete({ (R) in
                switch R{
                case .failure(let error):
                    print("******\(self.request?.host ?? "") serverChannel close error ! \(error.localizedDescription)")
                    break
                case .success(_):
                    self.session.end_time = NSNumber(value: Date().timeIntervalSince1970)
                    self.session.save()
                    break
                }
            })
        }
        get {
            return _serverChannel
        }
    }
    
    var request: ProxyRequest?
    var isHttp: Bool
    var isSSL: Bool = false
    
    var task: Task
    var session: Session

    init(isHttp: Bool = false, task: Task) {
        self.isHttp = isHttp
        self.task = task
        self.session = Session.newSession(task)
    }
    
    func replace(_ head: HTTPRequestHead) -> HTTPRequestHead {
        
        var newHead = HTTPRequestHead(version: head.version, method: head.method, uri: head.uri, headers: head.headers)
        
        let uri = newHead.uri
        if !uri.starts(with: "/"), let hostStr = head.headers["Host"].first {
            if let newUri = uri.components(separatedBy: hostStr).last {
                newHead.uri = newUri
            }
        }
        // 重定向修改host
        let newHost = self.task.rule.redirect(ignore: self.session.ignore, request: self.request!)
        newHead.headers.remove(name: "Host")
        newHead.headers.add(name: "Host", value: "\(newHost.0):\(newHost.1)")
        
        // query参数修改
        let query = self.task.rule.getFalsify(ignore: self.session.ignore, request: self.request!, type: 0, key: "req_param")
        if query != nil {
            let path = newHead.uri.split(separator: "?")[0]
            newHead.uri = "\(path)?\(query!.stringValue)"
        }
        
        return newHead
    }
}
