//
//  Task.swift
//  Runner
//
//  Created by Dubhe on 2023/8/13.
//

import Foundation
import SwiftyJSON

public class Task {
    public var id: NSNumber!
    public var localEnable: NSNumber = 1
    public var wifiEnable: NSNumber = 1
    
    public var rule: TaskRule!
    
    var startTime: NSNumber = 1
    var stopTime: NSNumber = 1
    
    var wifiIP: String = "127.0.0.1"
    var port: NSNumber = 9527

    init(arg: NSDictionary) {
        let json = JSON(arg)
        self.id = json["taskId"].numberValue
        self.rule = TaskRule(filter: json["filter"], falsify: json["falsify"].array)
    }
}

