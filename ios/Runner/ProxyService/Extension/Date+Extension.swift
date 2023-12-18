//
//  Date+Extension.swift
//  Runner
//
//  Created by dubhe on 2023/12/8.
//

import Foundation

extension Date {
    ///获取当前时间字符串
    public var fullSting:String{
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let dataString = dateFormatter.string(from: self)
        return dataString
    }
}
