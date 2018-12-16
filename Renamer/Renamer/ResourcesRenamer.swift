//
//  ResourcesRenamer.swift
//  Renamer
//
//  Created by JiangWang on 2018/12/14.
//  Copyright © 2018 JiangWang. All rights reserved.
//

import Foundation


/// The data structure to model asset image
struct AssetImage {
    var idiom = ""
    var scale = "1x"
    var fileName: String?
    /*
 {
 "images" : [
 {
 "idiom" : "universal",
 "scale" : "1x"
 },
 {
 "idiom" : "universal",
 "filename" : "2-1@2x.png",
 "scale" : "2x"
 },
 {
 "idiom" : "universal",
 "filename" : "2@3x.png",
 "scale" : "3x"
 }
 ],
 "info" : {
 "version" : 1,
 "author" : "xcode"
 }
 }
 */
}

/// Rename all files in the assets catalog
/// Assets 里面的名字是以文件夹命名的-修改原png的名字是没有用的
class ResourcesRenamer: Renamer {
    let console = ConsoleIO()
    
    /// The new prefix added directly to the resource file name
    public var newPrefix = ""
    
    /// The files to change in the directory below
    public var searchFilesPath = ""
    
    //MARK
    private func allowedFileExtensions() -> [String] {
        return ["imageset"]
    }
    
    private func searchFiles() -> [String] {
        let exts = ["h", "m"] //暂定h m -> storyboard也应该在里面
        return allFiles(withExts: exts, in: searchFilesPath)
    }

    /// rename all the resouces files
    public func rename() {
        dirs = allDirs(withExts: allowedFileExtensions(), in: workDir)
        let prjStr = try? String.init(contentsOfFile: projectFilePath)
        assert(prjStr != nil)
        projectStr = prjStr!
        
        //rename
        let modifyFiles = searchFiles()
        for dir in dirs {
            autoreleasepool(invoking: {
//                let renamed = rename(assetDir: dir, inFiles: modifyFiles)
//                if !renamed {
//                    console.writeMessage("failed to rename: " + dir, to: .error)
//                }
                renamePicFiles(in: dir)
            })
        }
        
        //remove old proj
//        try? fileManager.removeItem(atPath: projectFilePath)
//        let prjData = projectStr.data(using: .utf8)
//        fileManager.createFile(atPath: projectFilePath, contents: prjData, attributes: nil)
    }
    
    /// rename a resource file
    private func rename(assetDir: String, inFiles files: [String]) -> Bool {
        var ret = false
        let nsFile = assetDir as NSString
        var fileName = nsFile.lastPathComponent
        assert(hasValidExtension(fileName: fileName, validExts: allowedFileExtensions()))
        
        //remove path extension
        let pathExt = nsFile.pathExtension
        fileName = fileName.replacingOccurrences(of: "."+pathExt, with: "")
        
        if let newFileName = newFileName(with: fileName) {
            console.writeMessage("==============\n"
                + "rename: " + fileName + "\n"
                + "to: " + newFileName)
            
            //source files
            for anyFile in files {
                if let anyFileStr = try? String.init(contentsOfFile: anyFile) {
                    //pattern to replace "fileNmae
                    let oldPattern = "\""+fileName
                    let newPattern = "\""+newFileName
                    let fileContent = anyFileStr.replacingOccurrences(of: oldPattern, with: newPattern)
                    try? fileManager.removeItem(atPath: anyFile)
                    //creat new
                    let fileData = fileContent.data(using: .utf8)
                    fileManager.createFile(atPath: anyFile, contents: fileData, attributes: nil)
                }
                else {
                    console.writeMessage("failed to read: " + anyFile, to: .error)
                }
            }
            
            let newFilePath = assetDir.replacingOccurrences(of: fileName, with: newFileName)
            try? fileManager.moveItem(atPath: assetDir, toPath: newFilePath)
            //replace global files
            let index = self.dirs.firstIndex(of: assetDir)! //force
            self.dirs.remove(at: index)
            ret = true
        }
        
        return ret
    }
    
    /// Very often the pic file's names can be different with the name of
    /// the .imageset folder name
    /// This function tries to rename all pic files according to the .imageset folder
    /// name
    private func renamePicFiles(in assetDir: String) {
        let jsonFile = assetDir.appending("/"+"Contents.json")
        let jsonData = try! String.init(contentsOfFile: jsonFile).data(using: .utf8)
        let decoded = try? JSONSerialization.jsonObject(with: jsonData!, options: [])
        var images = [AssetImage]()
        if let jsonDict = decoded as? [String:AnyObject] {
            if let imageDicts = jsonDict["images"] as? Array<Dictionary<String, String>> {
                for image in imageDicts {
                    let idiom = image["idiom"] ?? ""
                    let scale = image["scale"] ?? "1x"
                    let fileName = image["filename"]
                    let assetImage = AssetImage.init(idiom: idiom, scale: scale, fileName: fileName)
                    images.append(assetImage)
                }
            }
        }
        
        var assetName = (assetDir as NSString).lastPathComponent
        //remove imageset
        assetName = assetName.replacingOccurrences(of: ".imageset", with: "")
        
        for image in images {
            if let imageName = image.fileName {
                let picFolder = assetDir
                
                let assetExt = (imageName as NSString).pathExtension
                let newImageName = assetName + "@" + image.scale + "." + assetExt
                
                let oldPicPath = picFolder + "/" + imageName
                let newPicPath = picFolder + "/" + newImageName
                do {
                    try fileManager.moveItem(atPath: oldPicPath, toPath: newPicPath)
                }
                catch {
                    print(error)
                }
                
                
                var jsonStr = try! String.init(contentsOfFile: jsonFile)
                let oldNamePattern = "\""+imageName+"\""
                let newNamePattern = "\""+newImageName+"\""
                jsonStr = jsonStr.replacingOccurrences(of: oldNamePattern, with: newNamePattern)
                let jsonData = jsonStr.data(using: .utf8)
                try? fileManager.removeItem(atPath: jsonFile)
                fileManager.createFile(atPath: jsonFile, contents: jsonData, attributes: nil)
            }
        }
    }
    
    /// custom file name logic
    private func newFileName(with old: String) -> String? {
        var new: String? = old
        new = newPrefix + "_" + old;
        return new
    }
}

