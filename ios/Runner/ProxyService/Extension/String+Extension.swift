//
//  String+Extension.swift
//  Runner
//
//  Created by Dubhe on 2023/8/15.
//

import UIKit
import NIO

public extension String{
    
    func isNumber() -> Bool {
        let pattern = "^[0-9]+$"
        if NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self) {
            return true
        }
        return false
    }
    
    func getRealType() -> String {
        if let t = self.components(separatedBy: ";").first {
            if let realType = t.components(separatedBy: "/").last {
                if realType.lowercased() == "text" {
                    return "txt"
                }
                if realType.lowercased() == "javascript" {
                    return "js"
                }
                return realType
            }
        }
        return ""
    }
    
    func getFileName() -> String {
        let uriParts = self.components(separatedBy: "?")
        if let fpart = uriParts.first {
            let paths = fpart.components(separatedBy: "/")
            if let lastPath = paths.last{
                return lastPath
            }
        }
        return ""
    }
    
    func isIP() -> Bool {
        var ipv4Addr = in_addr()
        var ipv6Addr = in6_addr()

        return self.withCString { ptr in
            return inet_pton(AF_INET, ptr, &ipv4Addr) == 1 ||
                   inet_pton(AF_INET6, ptr, &ipv6Addr) == 1
        }
    }
}
