//
//  SSLHandler.swift
//  Runner
//
//  Created by Dubhe on 2023/8/20.
//

import Foundation
import NIOTLS
import NIO
import NIOSSL
import NIOHTTP1


class SSLHandler: ChannelInboundHandler, RemovableChannelHandler {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = ByteBuffer
    
    var proxyContext: ProxyContext
    var scheduled: Scheduled<Void>
    
    init(proxyContext: ProxyContext,scheduled: Scheduled<Void>){
        self.proxyContext = proxyContext
        self.scheduled = scheduled
    }
    
    // 原始消息报文
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        scheduled.cancel()
        prepareProxyContext(context: context, data: data)
        //
        let buf = unwrapInboundIn(data)
        if buf.readableBytes < 3 {
            print("buf.readableBytes < 3")
            return
        }
        let first = buf.getBytes(at: buf.readerIndex, length: 1)
        let second = buf.getBytes(at: buf.readerIndex + 1, length: 1)
        let third = buf.getBytes(at: buf.readerIndex + 2, length: 1)
        let firstData = NSString(format: "%d", first?.first ?? 0).integerValue
        let secondData = NSString(format: "%d", second?.first ?? 0).integerValue
        let thirdData = NSString(format: "%d", third?.first ?? 0).integerValue
        if (firstData == 22 && secondData <= 3 && thirdData <= 3) {
            // is ClientHello
            proxyContext.isSSL = true
            // 通过CA证书给域名动态签发证书
//            let host = proxyContext.request!.host
            let redirect = proxyContext.task.rule.redirect(ignore: proxyContext.session.ignore, request: proxyContext.request!)
            var dynamicCert = CertUtils.certPool[redirect.0]
            if dynamicCert == nil {
                dynamicCert = CertUtils.generateSelfSignedCert(host: redirect.0)
                CertUtils.certPool[redirect.0] = dynamicCert
            }

            let tlsServerConfiguration = TLSConfiguration.makeServerConfiguration(certificateChain: [.certificate(dynamicCert as! NIOSSLCertificate)], privateKey: .privateKey(try! NIOSSLPrivateKey(bytes: privateKey, format: .pem)))
            let sslServerContext = try! NIOSSLContext(configuration: tlsServerConfiguration)
            let sslServerHandler = NIOSSLServerHandler(context: sslServerContext)
            // issue:握手信息发出后，服务器验证未通过，失败未关闭channel
            // 添加ssl握手处理handler
            let cancelHandshakeTask = context.channel.eventLoop.scheduleTask(in:  TimeAmount.seconds(10)) {
                print("error:can not get server hello from MITM \(self.proxyContext.request?.host ?? "")")

                context.channel.close(mode: .all,promise: nil)
            }
            let aPNHandler = ApplicationProtocolNegotiationHandler(alpnCompleteHandler: { result -> EventLoopFuture<Void> in
                cancelHandshakeTask.cancel()
                let requestDecoder = HTTPRequestDecoder(leftOverBytesStrategy: .dropBytes)
                return context.pipeline.addHandler(ByteToMessageHandler(requestDecoder), name: "ByteToMessageHandler").flatMap({
                    context.pipeline.addHandler(HTTPResponseEncoder(), name: "HTTPResponseEncoder").flatMap({                   // <--
                        context.pipeline.addHandler(HTTPServerPipelineHandler(), name: "HTTPServerPipelineHandler").flatMap({   // <-->
                            context.pipeline.addHandler(HTTPHandler(proxyContext: self.proxyContext), name: "HTTPHandler")      // -->
                        })
                    })
                })
            })
            
            _ = context.pipeline.addHandler(sslServerHandler, name: "NIOSSLServerHandler", position: .last)
            _ = context.pipeline.addHandler(aPNHandler, name: "ApplicationProtocolNegotiationHandler")
            context.fireChannelRead(self.wrapInboundOut(buf))
            _ = context.pipeline.removeHandler(name: "SSLHandler")
            return
        } else {
            print("+++++++++++++++ not ssl handshake ")
        }
    }
    
    func prepareProxyContext(context: ChannelHandlerContext, data: NIOAny) -> Void {
        if proxyContext.serverChannel == nil {
            proxyContext.serverChannel = context.channel
        }
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("SSLHandler errorCaught:\(error.localizedDescription)")
        context.channel.close(mode: .all, promise: nil)
    }
}
