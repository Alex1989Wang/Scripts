//
//  CodeInjector.swift
//  Renamer
//
//  Created by JiangWang on 2018/12/14.
//  Copyright © 2018 JiangWang. All rights reserved.
//

import Foundation

/// Read from trash code cgf files
/// Randomly inject tash code calls into your all your source files.
class CodeInjector {
    let fileManager = FileManager.default
    
    /// The config file
    public var cfgFile = ""
    
    /// The delimiter in cfg file - defaults to \n
    public var cfgDel: String = "\n"
    
    /// The directoy to search for source files
    public var sourceFilesDir = ""

    /// Inject trash code calls to searched source files.
    public func inject() {
        //filter empty string
        let snipets = trashSnipets(withFile: cfgFile, snipetSeparator: cfgDel)
        let files = allFiles(withExts: allowedFileExtensions(), in: sourceFilesDir)
        for file in files {
            _ = autoreleasepool(invoking: {
                inject(in: file, snipets: snipets)
            })
        }
    }
    
    public func removeInjection() {
        //remove directly
        let snipets = trashSnipets(withFile: cfgFile, snipetSeparator: cfgDel)
        let files = allFiles(withExts: allowedFileExtensions(), in: sourceFilesDir)
        for file in files {
            _ = autoreleasepool(invoking: {
                removeInjection(in: file, snipets: snipets)
            })
        }
    }
    
    private func allowedFileExtensions() -> [String] {
        return ["h", "m"]
    }
    
    private func inject(in file: String, snipets: [String]) -> Bool {
        print("==============\n"
            + "inject in: " + file)
        
        var ret = false
        let nsFile = file as NSString
        let fileName = nsFile.lastPathComponent
        assert(hasValidExtension(fileName: fileName, validExts: allowedFileExtensions()))
        
        //source files .h | .m
        if let fileStr = try? String.init(contentsOfFile: file) {
            //use regex to match method imps
            // (-|\+)\s?\(([\w|\*|\s]*)\)[^\}\{\\\/]*(\n|\s)\{
            let regexStr = "(-|\\+)\\s?\\(([\\w|\\*|\\s]*)\\)[^\\}\\{\\\\/]*(\\n|\\s)\\{"
            let regex = try! NSRegularExpression(pattern: regexStr, options: [.dotMatchesLineSeparators])
            let fullRange = NSRange.init(location: 0, length: fileStr.count)
            let nsFileStr = fileStr as NSString
            let matches = regex.matches(in: fileStr, options: [], range: fullRange).map {
                result in
                result.range.location != NSNotFound ?
                    nsFileStr.substring(with: result.range) : ""
            }
            
            var newFileStr = fileStr
            for oldPattern in matches {
                let randomIndex = Int.random(in: 0..<snipets.count)
                let newPattern = oldPattern + snipets[randomIndex]
                let firstOccur = newFileStr.range(of: oldPattern)
                newFileStr = newFileStr.replacingOccurrences(of: oldPattern, with: newPattern, options: .literal, range: firstOccur)
            }

            try? fileManager.removeItem(atPath: file)
            //creat new
            let fileData = newFileStr.data(using: .utf8)
            fileManager.createFile(atPath: file, contents: fileData, attributes: nil)
            ret = true
        }
        else {
            print("failed to read: " + file)
        }
        
        return ret
    }
    
    private func removeInjection(in file: String, snipets: [String]) {
        print("==============\n"
            + "remove injection in: " + file)
        
        let nsFile = file as NSString
        let fileName = nsFile.lastPathComponent
        assert(hasValidExtension(fileName: fileName, validExts: allowedFileExtensions()))
        
        //source files .h | .m
        if let fileStr = try? String.init(contentsOfFile: file) {
            var newFileStr = fileStr
            for trashSnipet in snipets {
                newFileStr = newFileStr.replacingOccurrences(of: trashSnipet, with: "")
            }

            try? fileManager.removeItem(atPath: file)
            //creat new
            let fileData = newFileStr.data(using: .utf8)
            fileManager.createFile(atPath: file, contents: fileData, attributes: nil)
        }
        else {
            print("failed to read: " + file)
        }
    }
    
    /// Find files with extension .h|.m
    private func allFiles(withExts extensions:[String], in dir:String) -> [String] {
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
    
    /// validate file extensions
    public func hasValidExtension(fileName: String, validExts:[String]) -> Bool {
        var valid = false
        let nsFile: NSString = fileName as NSString
        let pathExt = nsFile.pathExtension
        valid = validExts.contains(pathExt)
        return valid
    }
    
    private func trashSnipets(withFile configFile: String, snipetSeparator: String) -> [String] {
        let cfgContens = try? String.init(contentsOfFile: configFile)
        assert(cfgContens != nil, "no trash calls to inject")
        //filter empty string
        let trashSnipets = cfgContens!.components(separatedBy: snipetSeparator).filter {
            (string) -> Bool in
            return string.count != 0
        }
        return trashSnipets
    }
}
