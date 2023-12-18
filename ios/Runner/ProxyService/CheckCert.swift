//
//  SSLService.swift
//  Runner
//
//  Created by dubhe on 2023/12/15.
//

import Foundation
import NIO
import NIOSSL
import NIOTLS
import NIOConcurrencyHelpers

fileprivate let SSLHost = "www.localhost.com"

private final class EchoHandler: ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        context.write(data, promise: nil)
    }
    
    func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        // 添加日志输出来监控错误
        print("EchoHandler caught an error: \(error)")
        context.close(promise: nil)
    }
}

private class LocalSSLService {
    var host: String
    var port: Int
    
    var group: MultiThreadedEventLoopGroup?
    var channel: Channel?
    
    var sslContext: NIOSSLContext!
    public var cacert: NIOSSLCertificate!
    public var cakey: NIOSSLPrivateKey!
    public var rsakey: NIOSSLPrivateKey!
    
    public init(host: String, port: Int) {
        self.host = host
        self.port = port
    }
    
    public func run(_ callBack: @escaping (Bool) -> Void) -> Void {
        let dynamicCert = CertUtils.generateSelfSignedCert(host: SSLHost)
        let tlsServerConfiguration = TLSConfiguration.makeServerConfiguration(certificateChain: [.certificate(dynamicCert)], privateKey: .privateKey(try! NIOSSLPrivateKey(bytes: privateKey, format: .pem)))
        sslContext = try! NIOSSLContext(configuration: tlsServerConfiguration)
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let bootstrap = ServerBootstrap(group: group!)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelInitializer { channel in
                return channel.pipeline.addHandler(NIOSSLServerHandler(context: self.sslContext)).flatMap {
                    channel.pipeline.addHandler(EchoHandler())
                }
            }
            .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
        
        DispatchQueue.global().async {
            do {
                self.channel = try bootstrap.bind(host: self.host, port: self.port).wait()
                callBack(true)
                try self.channel?.closeFuture.wait()
            } catch {
                callBack(false)
            }
        }
    }
    
    public func close() {
        channel?.close(mode: .all).whenSuccess({ () in
        })
//        try? group?.syncShutdownGracefully()
    }
}

public enum TrustResultType:String {
    case none = "none"
    case installed = "installed"
    case trusted = "trusted"
}

public class CheckCert {
    var checkCallBack: ((TrustResultType) -> Void)!
    private var sslServer: LocalSSLService?
    var isEnd = false
    let host: String = "127.0.0.1"
    let port: Int = 4433
    
    public static func checkPermissions(_ callBack: @escaping (TrustResultType) -> Void){
        let check = CheckCert()
        check.isTrust(callBack)
    }
    
    public func isTrust(_ callBack: @escaping (TrustResultType) -> Void){
        checkCallBack = callBack
        // 启动ssl服务，检查是否信任证书
        sslServer = LocalSSLService(host: host, port: port)
        sslServer?.run({ [self] (success) in
            if !success {
                self.isEnd = true
                self.checkCallBack(.installed)
                return
            }
            self.check()
        })
    }
    
    func check(){
        let channelInitializer: ((Channel) -> EventLoopFuture<Void>) = { (channel) -> EventLoopFuture<Void> in
            var tlsClientConfiguration = TLSConfiguration.makeClientConfiguration()
            tlsClientConfiguration.applicationProtocols = ["http/1.1"]
            let sslClientContext = try! NIOSSLContext(configuration: tlsClientConfiguration)
            let sslClientHandler = try! NIOSSLClientHandler(context: sslClientContext, serverHostname: SSLHost)
            let applicationProtocolNegotiationHandler = ApplicationProtocolNegotiationHandler { (result) -> EventLoopFuture<Void> in
                // ssl握手成功
                self.isEnd = true
                self.checkCallBack(.trusted)
                return channel.close(mode: .all)
            }
            return channel.pipeline.addHandler(sslClientHandler, name: "NIOSSLClientHandler").flatMap({
                channel.pipeline.addHandler(applicationProtocolNegotiationHandler, name: "ApplicationProtocolNegotiationHandler")
            })
        }
        
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let clientBootstrap = ClientBootstrap(group: group).channelInitializer(channelInitializer)
        let cf = clientBootstrap.connect(host: host, port: port)
        cf.whenComplete { result in
            switch result {
            case .success(let channel):
                channel.closeFuture.whenComplete({ (R) in
                    switch R {
                    case .failure(let error):
                        print("SSL Client Channel Close Error ! \(error.localizedDescription)")
                    case .success(_):
                        print("SSL Client Channel Close Success !")
                        break
                    }
                    if !self.isEnd {
                        self.isEnd = true
                        self.checkCallBack(.installed)
                    }
                    print("SSL Client Close !")
                    self.sslServer?.close()
//                    try? group.syncShutdownGracefully()
                })
                print("SSL Client Connect Success ! \(channel.remoteAddress?.description ?? "")")
                break
            case .failure(let error):
                self.isEnd = true
                self.checkCallBack(.installed)
                print("SSL Client Connect failure:\(error)")
                break
            }
        }
    }
}
