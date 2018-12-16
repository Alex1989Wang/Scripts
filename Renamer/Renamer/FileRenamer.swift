//
//  FileRenamer.swift
//  Renamer
//
//  Created by JiangWang on 2018/12/14.
//  Copyright © 2018 JiangWang. All rights reserved.
//

import Foundation

class FileRenamer: Renamer {
    let console = ConsoleIO()
    
    public var prefix = "OLD_FILE_PREFIX" //
    public var newPrefix = "NEW_FILE_PREFIX" //
    
    //MARK: overrides
    private func allowedFileExtensions() -> [String] {
        return ["h", "m", "xib"] //.h|.m|.xib
    }
    
    /// start renaming files
    public func rename() {
        files = allFiles(withExts: allowedFileExtensions(), in: workDir)
        let prjStr = try? String.init(contentsOfFile: projectFilePath)
        assert(prjStr != nil)
        projectStr = prjStr!
        
        //rename
        for file in files {
            autoreleasepool(invoking: {
                let renamed = rename(file: file, project: projectStr)
                if !renamed {
                    console.writeMessage("failed to rename: " + file, to: .error)
                }
            })
        }
        
        //remove old proj
        try? fileManager.removeItem(atPath: projectFilePath)
        let prjData = projectStr.data(using: .utf8)
        fileManager.createFile(atPath: projectFilePath, contents: prjData, attributes: nil)
    }
    
    
    /// rename a single file
    private func rename(file: String, project: String) -> Bool {
        var ret = false
        let nsFile = file as NSString
        let fileName = nsFile.lastPathComponent
        assert(hasValidExtension(fileName: fileName, validExts: allowedFileExtensions()))

        if let newFileName = newFileName(with: fileName) {
            console.writeMessage("==============\n"
                + "rename: " + fileName + "\n"
                + "to: " + newFileName)
            
            //project file substitution
            projectStr = project.replacingOccurrences(of: fileName, with: newFileName)
            
            //source files import && xib
            for anyFile in files {
                if let anyFileStr = try? String.init(contentsOfFile: anyFile) {
                    let fileContent = anyFileStr.replacingOccurrences(of: fileName, with: newFileName)
                    try? fileManager.removeItem(atPath: anyFile)
                    //creat new
                    let fileData = fileContent.data(using: .utf8)
                    fileManager.createFile(atPath: anyFile, contents: fileData, attributes: nil)
                }
                else {
                    console.writeMessage("failed to read: " + anyFile, to: .error)
                }
            }
            
            let newFilePath = file.replacingOccurrences(of: fileName, with: newFileName)
            try? fileManager.moveItem(atPath: file, toPath: newFilePath)
            //replace global files
            let index = files.firstIndex(of: file)! //force
            files.remove(at: index)
            files.append(newFilePath)
            ret = true
        }
        
        return ret
    }
    
    private func newFileName(with old: String) -> String? {
        var new: String? = old
        new = old.contains(prefix) ? old.replacingOccurrences(of: prefix, with: newPrefix) : nil
        return new
    }
}
