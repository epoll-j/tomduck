//
//  ProxyService.swift
//  Runner
//
//  Created by Dubhe on 2023/8/12.
//

import Foundation
import NIO
import NIOHTTP1

public let GROUP_NAME = "cn.tomduck.app"
public let DEFAULT_PORT: NSNumber = 9527

public class ProxyService: NSObject {
    
    enum ServiceState {
        case initial
        case running
        case closed
        case failure
    }
    
    var task: CaughtTask!
    let master = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    let worker = MultiThreadedEventLoopGroup(numberOfThreads: 3 * System.coreCount)
    
    var wifiBootstrap: ServerBootstrap!
    var wifiChannel: Channel!
    var wifiBindIP = ""
    var wifiBindPort = -1
    var wifiStarted = ServiceState.initial
    
    var compelete: ((Result<Int, Error>) -> Void)?
    var closed: (() -> Void)?
    
    public init(task: CaughtTask) {
        super.init()
        self.task = task
        let protocolDetector = ProtocolDetector(task: task ,matchers: [HTTPMatcher(), HTTPSMatcher()])
        
        wifiBootstrap = ServerBootstrap(group: master, childGroup: worker)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelInitializer({ channel in
                channel.pipeline.addHandler(protocolDetector, name: "ProtocolDetector", position: .first)
            })
            .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
            .childChannelOption(ChannelOptions.allowRemoteHalfClosure, value: false)
            .childChannelOption(ChannelOptions.connectTimeout, value: TimeAmount.seconds(10))
    }
    
    public static func create() -> ProxyService? {
        return ProxyService(task: CaughtTask())
    }
    
    public func run(_ callback: @escaping ((Result<Int, Error>) -> Void)) -> Void {
        compelete = callback
        task.startTime = NSNumber(value: Date().timeIntervalSince1970)
        DispatchQueue.global().async {
            self.openWifiServer(host: NetworkInfo.LocalWifiIPv4(), port: Int(truncating: DEFAULT_PORT)) { _ in
                self.runCompelete()
            }
        }
    }
    
    public func openWifiServer(host: String, port: Int, _ callback: ((Result<Int, Error>) -> Void)?) {
        wifiChannel = try? wifiBootstrap.bind(host: host, port: port).wait()
        if wifiChannel == nil {
            wifiStarted = .failure
            return
        }
        
        guard let localAddress = wifiChannel.localAddress else {
            wifiStarted = .failure
            return
        }
        
        wifiStarted = .running
        callback?(.success(1))
        try? wifiChannel.closeFuture.wait()
        wifiStarted = .closed
    }
    
    private func runCompelete() {
        self.compelete?(.success(1))
    }
}
