//
//  TaskRule.swift
//  Runner
//
//  Created by dubhe on 2023/11/10.
//

import Foundation
import SwiftyJSON
import NIOHTTP1

public class TaskRule {
    public var filter: JSON?
    public var falsify: [JSON]?
    
    init(filter: JSON? = nil, falsify: [JSON]? = nil) {
        self.filter = filter
        self.falsify = falsify
    }
    
    func matchFilter(_ url: String) -> Bool {
        let type = self.filter?["type"].intValue ?? -1
        let domainList = self.filter?["domain"].arrayObject ?? []
        if type != -1 {
            for domain in domainList {
                if _uriMatch(url, match: (domain as! String)) {
                    return type == 1
                }
            }
        }
        
        if type == -1 {
            return false
        } else {
            return type == 0
        }
    }
    
    func matchFalsify() -> JSON {
        return JSON()
    }
    
    private func _uriMatch(_ uri: String, match: String) -> Bool {
        let remove443 = uri.replacingOccurrences(of: ":443", with: "")
        if (match.contains("*")) {
            return remove443.matchesWildcardPattern(match)
        } else {
            let target = remove443.replacingOccurrences(of: "http://", with: "").replacingOccurrences(of: "https://", with: "").split(separator: "?")[0]
            return match == target
        }
    }
    
    
    
    func redirect(ignore: Bool, request: ProxyRequest) -> (String, Int) {
//        return ("ffapi.ude.alibaba.net", 80)
        
        if (ignore) {
            return (request.host, request.port)
        }
        
        let item = _matchFalsify(request.head.uri, type: 1)
        let newHost = (item?["redirect_host"].stringValue.isEmpty ?? true) ? request.host : (item?["redirect_host"].string ?? request.host)
        let newPort = (item?["redirect_port"].stringValue.isEmpty ?? true) ? request.port : (item?["redirect_port"].int ?? request.port)
        return (newHost, newPort)
    }
    
    func getFalsify(ignore: Bool, request: ProxyRequest, type: Int, key: String? = nil) -> JSON? {
        if (ignore) {
            return nil
        }
        
        return _matchFalsify(request.head.uri, type: type, key: key)
    }
    
    private func _matchFalsify(_ uri: String, type: Int = 0, key: String? = nil) -> JSON? {
        if falsify != nil {
            for item in falsify! {
                let itemUri = item["uri"].stringValue
                if _uriMatch(uri, match: itemUri) && item["action"].intValue == type {
                    if key == nil {
                        return item
                    } else {
                        if !item[key!].stringValue.isEmpty {
                            return item[key!]
                        }
                    }
                    
                }
            }
        }
        
        return nil
    }
    
}
