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
    
    var task: Task!
    public static var storeFolder = ""
    let master = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    let worker = MultiThreadedEventLoopGroup(numberOfThreads: 3 * System.coreCount)
    
    var wifiBootstrap: ServerBootstrap!
    var wifiChannel: Channel!
    var wifiBindIP = ""
    var wifiBindPort = -1
    var wifiState = ServiceState.initial
    
    var compelete: ((Result<Int, Error>) -> Void)?
    var closed: (() -> Void)?
    
    public init(task: Task) {
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
    
    public static func create(_ arg: NSDictionary) -> ProxyService? {
        return ProxyService(task: Task(arg: arg))
    }
    
    public func run(_ callback: @escaping ((Result<Int, Error>) -> Void)) -> Void {
        compelete = callback
        task.startTime = NSNumber(value: Date().timeIntervalSince1970)
        task.createFileFolder()
        DispatchQueue.global().async {
            self.openWifiServer(host: "0.0.0.0", port: Int(truncating: DEFAULT_PORT)) { _ in
                self.runCompelete()
            }
        }
    }
    
    public func openWifiServer(host: String, port: Int, _ callback: ((Result<Int, Error>) -> Void)?) {
        wifiChannel = try? wifiBootstrap.bind(host: host, port: port).wait()
        if wifiChannel == nil {
            wifiState = .failure
            return
        }
        
        guard (wifiChannel.localAddress) != nil else {
            wifiState = .failure
            return
        }
        
        wifiState = .running
        callback?(.success(1))
        try? wifiChannel.closeFuture.wait()
        wifiState = .closed
    }
    
    private func runCompelete() {
        self.compelete?(.success(1))
    }
    
    public func close(_ completionHandler: (() -> Void)?) -> Void {
        closed = completionHandler
        task.stopTime = NSNumber(value: Date().timeIntervalSince1970)
        
        if let callback = completionHandler {
            callback()
        }
        
        closeWifiServer()
        
        master.shutdownGracefully { (error) in
            if let e = error {
                print("master thread of eventloop close error:\(e.localizedDescription)")
            }
        }
        worker.shutdownGracefully { (error) in
            if let e = error {
                print("worker thread of eventloop close error:\(e.localizedDescription)")
            }
        }
    }
    
    public func closeWifiServer(){
        if wifiChannel == nil {
            return
        }
        wifiChannel.close(mode: .input).whenComplete { (r) in
            self.wifiState = .closed
            switch r {
            case .success:
                self.wifiChannel = nil
                break
            case .failure(_):
                break
            }
        }
    }
    
    public static func getStoreFolder() -> String {
        if storeFolder != "" {
           return storeFolder
        }
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let storeURL = documentsDirectory.appendingPathComponent("Task")
        var isDir : ObjCBool = false
        let isExits = fileManager.fileExists(atPath: storeURL.absoluteString, isDirectory: &isDir)
        if isExits {
            if isDir.boolValue {
                return storeURL.absoluteString
            } else {
                try? fileManager.removeItem(at: storeURL)
            }
        }
        try? fileManager.createDirectory(at: storeURL, withIntermediateDirectories: true, attributes: nil)
        let fullPath = storeURL.absoluteString
       
        storeFolder = fullPath.replacingOccurrences(of: "file://", with: "")
        if storeFolder.last != "/"{
           storeFolder = "\(storeFolder)/"
        }
       
        return storeFolder
   }
    
    public static func getCertPath() -> URL? {
        let fileManager = FileManager.default
        var certDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        certDirectory.appendPathComponent("Cert")
        let dir = certDirectory.absoluteString.components(separatedBy: "file://").last
        let isExits = fileManager.fileExists(atPath: dir!, isDirectory:nil)
        if !isExits {
            try? fileManager.createDirectory(at: certDirectory, withIntermediateDirectories: false, attributes: nil)
        }
        return certDirectory
    }
    
    private static func saveCert() {
        let fileManager = FileManager.default
        if let certDir = self.getCertPath() {
            let certPath = certDir.appendingPathComponent("cert.pem", isDirectory: false)
            if !fileManager.fileExists(atPath: certPath.absoluteString) {
                try? String(data: Data(cert), encoding: .utf8)?.write(to: certPath, atomically: true, encoding: .utf8)
            }
        }
    }
}
