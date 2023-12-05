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
    
    public var fileFolder = ""
    
    public var rule: TaskRule!
    
    var startTime: NSNumber = 1
    var stopTime: NSNumber = 1
    
    var wifiIP: String = "127.0.0.1"
    var port: NSNumber = 9527
    
    var createTime: NSNumber = 1
    
    init(arg: NSDictionary) {
        let json = JSON(arg)
        self.id = json["taskId"].numberValue
        self.rule = TaskRule(filter: json["filter"], falsify: json["falsify"].array)
        
        fileFolder = "task-\(id ?? -1)"
    }
    
    func getFullPath() -> String {
        var filePath = ProxyService.getStoreFolder()
        filePath.append(fileFolder)
        return filePath
    }
    
    func createFileFolder(){
        let filePath = getFullPath()
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        let isExits = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if isExits, isDir.boolValue {
            let errorStr = "Delete \(fileFolder)，Because it's not a folder !"
            NSLog(errorStr)
            try? fileManager.removeItem(atPath: filePath)
            try? fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
        }
        if !isExits {
            try? fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
        }
    }
}

