//
//  LocalizationRenamer.swift
//  Renamer
//
//  Created by JiangWang on 2018/12/16.
//  Copyright © 2018 JiangWang. All rights reserved.
//

import Foundation

/// Rename the localization .strings files
/// Search the source files in search folder and replace localization keys
class LocalizationRenamer: Renamer {
    
    /// The search directory to search for code source files
    public var searchDir = ""
    
    /// .strings file dir
    public var localizationDir = "XXX/Localization/Base.lproj"
    
    public func rename() {
        let keys = localizationKeys(in: localizationDir)
        let files = allFiles(withExts: ["h", "m", "strings"], in: searchDir)
        renameKeys(keys, in: files)
    }
    
    private func localizationKeys(in dir: String) -> [String] {
        var keys = [String]()
        let localizationFilePath = dir + "/" + "Localizable.strings"
        assert(fileManager.fileExists(atPath: localizationFilePath), "base localization must exist")
        let content = try! String.init(contentsOfFile: localizationFilePath)
        //regular express
        //\".+=.+\;
        let regExpr = try! NSRegularExpression.init(pattern: "\\\".+=.+\\;", options: [])
        let fullRange = NSRange.init(location: 0, length: content.count)
        let localizations = regExpr.matches(in: content, options: [], range: fullRange).map({
            result -> String in
            if result.range.location != NSNotFound {
                let matchStart = content.index(content.startIndex, offsetBy: result.range.location)
                let matchEnd = content.index(matchStart, offsetBy: result.range.length)
                return String(content[matchStart..<matchEnd])
            }
            else {
                return ""
            }
        })
        
        for localization in localizations {
            let keyValues: [String] = localization.components(separatedBy: "=")
            assert(keyValues.count == 2, "key and value all should exist")
            let key = keyValues[0]
            keys.append(key.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return keys
    }
    
    private func renameKeys(_ keys: [String], in files: [String]) {
        for file in files {
            autoreleasepool(invoking: {
                var fileContent = try! String.init(contentsOfFile: file)
                for key in keys {
                    let oldPattern = key //has "" included
                    let newPattern = newKey(withOld: key)
                    fileContent = fileContent.replacingOccurrences(of: oldPattern, with: newPattern)
                }

                let fileData = fileContent.data(using: .utf8)
                try? fileManager.removeItem(atPath: file)
                fileManager.createFile(atPath: file, contents: fileData, attributes: nil)
            })
        }
    }
    
    private func newKey(withOld key: String) -> String {
        assert(key.hasPrefix("\"") && key.hasSuffix("\"")
            , "key must have \" for both of its prefix and suffix")
        var newKey = key
        newKey.insert(contentsOf: "XXX_", at: newKey.index(after: newKey.startIndex))
        newKey.insert(contentsOf: "_REPLACED", at: newKey.index(before: newKey.endIndex))
        return newKey
    }
}
