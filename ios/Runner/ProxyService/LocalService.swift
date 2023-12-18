//
//  LocalService.swift
//  Runner
//
//  Created by dubhe on 2023/12/8.
//

import UIKit
import NIO
import NIOHTTP1
import Reachability

public let LocalHTTPServerChanged: NSNotification.Name = NSNotification.Name(rawValue: "LocalHTTPServerChanged")

public class LocalService {
    
    let reachability = try! Reachability()
    
    public static let httpRootPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("htdocs")
    
    let defaultHost = "0.0.0.0"
    let defaultPort = 8080
    let htdocs: String = LocalService.httpRootPath.absoluteString.components(separatedBy: "file://").last ?? ""
    
    var group: MultiThreadedEventLoopGroup?
    var threadPool: NIOThreadPool?
    
    var channel: Channel?
    
    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi, .cellular:
            runAgain()
        case .unavailable:
            close()
        }
    }
    
    deinit {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    func newBootstrap() -> ServerBootstrap {
        let fileIO = NonBlockingFileIO(threadPool: threadPool!)
        let bootstrap = ServerBootstrap(group: group!)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline(withErrorHandling: true).flatMap {
                    channel.pipeline.addHandler(HTTPServerHandler(fileIO: fileIO, htdocsPath: self.htdocs))
                }
            }
            .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
            .childChannelOption(ChannelOptions.allowRemoteHalfClosure, value: true)
        return bootstrap
    }
    
    func runLocal() {
        let bootstrap = newBootstrap()
        DispatchQueue.global().async {
            do {
                self.channel = try bootstrap.bind(host: self.defaultHost, port: self.defaultPort).wait()
                guard (self.channel?.localAddress) != nil else {
                    fatalError("HTTPServer(Local):Address was unable to bind:\(self.defaultHost):\(self.defaultPort)")
                }
                self.channel?.closeFuture.whenComplete({ (r) in
                    DispatchQueue.main.async { NotificationCenter.default.post(name: LocalHTTPServerChanged, object: ["local": false])}
                })
                DispatchQueue.main.async { NotificationCenter.default.post(name: LocalHTTPServerChanged, object: ["local": true]) }
                try self.channel?.closeFuture.wait()
            } catch {
                print("HTTPServer(Local):Server started failure:\(error.localizedDescription)")
            }
        }
    }
    
    public func run(){
        threadPool = NIOThreadPool(numberOfThreads: 6)
        threadPool?.start()
        group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        if threadPool == nil {
            print("LocalHTTPServer run failured !")
            return
        }

        runLocal()
    }
    
    func runAgain() {
        close()
        run()
    }
    
    public func close() {
        do {
            channel?.close().whenComplete({ result in
                switch result {
                case .success:
                    self.channel = nil
                    break
                case .failure(_):
                    break
                }
            })
            try group?.syncShutdownGracefully()
            try threadPool?.syncShutdownGracefully()
        } catch {
            print("Resources release failure !\(error.localizedDescription)")
        }
    }
}
