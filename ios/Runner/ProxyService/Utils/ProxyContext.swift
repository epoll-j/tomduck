//
//  ProxyContext.swift
//  Runner
//
//  Created by Dubhe on 2023/8/15.
//

import UIKit
import NIO
import NIOSSL

class ProxyContext: NSObject {
    
    var cert: NIOSSLCertificate?
    var pkey: NIOSSLPrivateKey?
    
    var _clientChannel: Channel?
    var clientChannel: Channel?{
        set {
            _clientChannel = newValue
            _clientChannel?.closeFuture.whenComplete({ (R) in
                switch R {
                case .failure(let error):
                    print("******\(self.request?.host ?? "") clientChannel close error ! \(error.localizedDescription)")
                    break
                case .success(_):
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
    var serverChannel: Channel?{
        set {
            _serverChannel = newValue
            _serverChannel?.closeFuture.whenComplete({ (R) in
                switch R{
                case .failure(let error):
                    print("******\(self.request?.host ?? "") serverChannel close error ! \(error.localizedDescription)")
                    break
                case .success(_):
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
    
    var task: CaughtTask

    init(isHttp: Bool = false, task: CaughtTask) {
        self.isHttp = isHttp
        self.task = task
    }
}
