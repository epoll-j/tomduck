//
//  ExchangeHandler.swift
//  Runner
//
//  Created by Dubhe on 2023/8/15.
//

import Foundation
import NIO
import NIOHTTP1
import NIOFoundationCompat

class ExchangeHandler: ChannelInboundHandler, RemovableChannelHandler {
    typealias InboundIn = HTTPClientResponsePart
    typealias OutboundOut = HTTPServerResponsePart
    
    var isSendBody = false
    var proxyContext: ProxyContext
    var gotEnd: Bool = false
    init(proxyContext: ProxyContext) {
        self.proxyContext = proxyContext
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let res = self.unwrapInboundIn(data)
        switch res {
        case .head(let head):
            proxyContext.session.response_start_time = NSNumber(value: Date().timeIntervalSince1970) // 开始接收响应
            proxyContext.session.response_http_version = "\(head.version)"
            proxyContext.session.http_code = "\(head.status.code)"
            proxyContext.session.response_msg = head.status.reasonPhrase
            let contentType = head.headers["Content-Type"].first ?? ""
            proxyContext.session.response_content_type = contentType
            if let ss = contentType.components(separatedBy: ";").first {
                proxyContext.session.suffix = ss.components(separatedBy: "/").last ?? ""
            }
            proxyContext.session.response_content_encoding = head.headers["Content-Encoding"].first ?? ""
            proxyContext.session.response_header = Session.getHeadsJson(headers: head.headers)//
            proxyContext.session.save()
            _ = proxyContext.serverChannel?.writeAndFlush(HTTPServerResponsePart.head(head))
        case .body(let body):
            let respBody = proxyContext.task.rule.getFalsify(ignore: proxyContext.session.ignore, request: proxyContext.request!, type: 0, key: "resp_body")
            if respBody != nil {
                if (!isSendBody) {
                    isSendBody = true
                    for buff in respBody!.stringValue.toByteBuffer() {
                        _ = proxyContext.serverChannel?.writeAndFlush(HTTPServerResponsePart.body(.byteBuffer(buff)))
                    }
                }
            } else {
                _ = proxyContext.serverChannel?.writeAndFlush(HTTPServerResponsePart.body(.byteBuffer(body)))
            }
            
            if proxyContext.session.fileName.isEmpty {
                if let fileName = proxyContext.session.uri?.getFileName() {
                    proxyContext.session.fileName = fileName
                    proxyContext.session.save()
                }
                let nameSplit = proxyContext.session.fileName.components(separatedBy: ".")
                if nameSplit.count < 2 {
                    let type = proxyContext.session.response_content_type!.getRealType()
                    if !type.isEmpty {
                        proxyContext.session.fileName = "\(proxyContext.session.fileName).\(type)"
                        proxyContext.session.save()
                    }
                }
                
            }
            
            proxyContext.session.writeBody(type: .Response, buffer: body, realName: proxyContext.session.fileName)
        case .end(let tailHeaders):
            proxyContext.session.response_end_time = NSNumber(value: Date().timeIntervalSince1970) // 接收完毕响应
            proxyContext.session.save()
            gotEnd = true
            proxyContext.session.writeBody(type: .Response, buffer: nil, realName: proxyContext.session.fileName)
            let promise = proxyContext.serverChannel?.eventLoop.makePromise(of: Void.self)
            proxyContext.serverChannel?.writeAndFlush(HTTPServerResponsePart.end(tailHeaders), promise: promise)
            promise?.futureResult.whenComplete({ (_) in
                if self.proxyContext.serverChannel!.isActive {
                    self.proxyContext.serverChannel!.close(mode: .all, promise: nil)
                }
            })
            let outPromise = context.eventLoop.makePromise(of: Void.self)
            context.channel.close(mode: .all, promise: outPromise)
            outPromise.futureResult.whenComplete { (_) in
            }
            return
        }
        context.fireChannelRead(data)
        
    }
    
    func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }
    
    func channelUnregistered(context: ChannelHandlerContext) {
        context.close(mode: .all, promise: nil)
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        if let channelError = error as? ChannelPipelineError {
            if channelError == .notFound && proxyContext.request!.ssl {
                return
            }
        }
        
        context.channel.close(mode: .all,promise: nil)

        if proxyContext.serverChannel!.isActive {
            _ = self.proxyContext.serverChannel!.close(mode: .all)
        }
    }
    
    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {

    }
}
