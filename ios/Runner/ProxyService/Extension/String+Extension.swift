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

    func toByteBuffer(_ limit: Int = 2048) -> [ByteBuffer] {
        var bufferArray: [ByteBuffer] = []
        let strArr = self.toArray(by: limit)
        
        for str in strArr {
            var buffer = ByteBufferAllocator().buffer(capacity: limit)
            buffer.writeString(str)
            bufferArray.append(buffer)
        }
        return bufferArray
    }
    
    func matchesWildcardPattern(_ pattern: String) -> Bool {
        let regexPattern = pattern.replacingOccurrences(of: "*", with: ".*")
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: .caseInsensitive)
            return !regex.matches(in: self, range: NSRange(location: 0, length: self.utf16.count)).isEmpty
        } catch {
            print("正则表达式创建失败：\(error)")
            return false
        }
    }
    
    func clearFormat() -> String {
        return self.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\\", with: "")
    }
    
    func get(_ empty: String) -> String {
        if self.isEmpty || self == "" {
            return empty
        }
        return self
    }
    
    func toArray(by length: Int) -> [String] {
        var result = [String]()
        var currentIndex = startIndex
        
        while currentIndex < endIndex {
            let endIndex = self.index(currentIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            let substring = self[currentIndex..<endIndex]
            result.append(String(substring))
            currentIndex = endIndex
        }
        
        return result
    }
}
