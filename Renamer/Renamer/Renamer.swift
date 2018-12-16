//
//  Renamer.swift
//  Renamer
//
//  Created by JiangWang on 2018/12/14.
//  Copyright © 2018 JiangWang. All rights reserved.
//

import Cocoa

class Renamer {
    
    /// The file manager to use
    public let fileManager = FileManager.default
    
    /// The directory to work on
    public var workDir = ""
    
    /// The path for project file
    public var projectFilePath = ""
    
    /// The content of the project file in String format
    public var projectStr = ""
    
    /// The array to store files' paths
    public var files = [String]()

    /// The array to store dirs to rename
    public var dirs = [String]()
    
    /// Find files with extension .xib|.h|.m
    public func allFiles(withExts extensions:[String], in dir:String) -> [String] {
        var files = [String]()
        let contents = try? fileManager.contentsOfDirectory(atPath: dir)
        if let contentList = contents {
            for content in contentList {
                let fullPath = dir.appending("/"+content)
                var isDir: ObjCBool = false
                fileManager.fileExists(atPath: fullPath, isDirectory: &isDir)
                if isDir.boolValue {
                    let subFiles = allFiles(withExts: extensions, in: fullPath)
                    files.append(contentsOf: subFiles)
                    continue
                }
                
                //not dir - extension match
                if hasValidExtension(fileName:content, validExts:extensions) {
                    files.append(fullPath)
                }
            }
        }
        return files
    }
    
    public func allDirs(withExts extensions:[String], in dir:String) -> [String] {
        var dirs = [String]()
        let contents = try? fileManager.contentsOfDirectory(atPath: dir)
        if let contentList = contents {
            for content in contentList {
                let fullPath = dir.appending("/"+content)
                var isDir: ObjCBool = false
                fileManager.fileExists(atPath: fullPath, isDirectory: &isDir)
                if isDir.boolValue {
                    //is right dir
                    if hasValidExtension(fileName: content, validExts: extensions) {
                        if !isDirectoryEmpty(dir: fullPath) {
                            dirs.append(fullPath)
                        }
                        else {
                            try? fileManager.removeItem(atPath: fullPath)
                        }
                        continue
                    }

                    let subDirs = allDirs(withExts: extensions, in: fullPath)
                    dirs.append(contentsOf: subDirs)
                }
            }
        }
        return dirs
    }
    
    /// validate file extensions
    public func hasValidExtension(fileName: String, validExts:[String]) -> Bool {
        var valid = false
        let nsFile: NSString = fileName as NSString
        let pathExt = nsFile.pathExtension
        valid = validExts.contains(pathExt)
        return valid
    }
    
    public func isDirectoryEmpty(dir: String) -> Bool {
        var empty = true
        let contents = try? fileManager.contentsOfDirectory(atPath: dir)
        empty = (contents == nil) || (contents!.count == 0)
        return empty
    }
}
