//
//  main.swift
//  Renamer
//
//  Created by JiangWang on 2018/12/13.
//  Copyright © 2018 JiangWang. All rights reserved.
//

import Foundation

//rename source files
//let fileRenamer = FileRenamer()
//fileRenamer.workDir = "XXX"
//fileRenamer.projectFilePath = "XXX.xcodeproj/project.pbxproj"
//fileRenamer.prefix = "OLD_FILE_PREFIX" //The old objective-c source file's prefix used in your project
//fileRenamer.newPrefix = "NEW_FILE_PREFIX" //The new prefix to replace the old one
//fileRenamer.rename()

//rename resource files - files in assets catlog
//let resourcesRenamer = ResourcesRenamer()
//resourcesRenamer.workDir = "XXX/Images.xcassets"
//resourcesRenamer.projectFilePath = "XXX.xcodeproj/project.pbxproj"
//resourcesRenamer.newPrefix = "NEW_ASSET_PREFIX" //The new prefix to add
//resourcesRenamer.searchFilesPath = "XXX"
//resourcesRenamer.rename()

//code injection
//let injecter = CodeInjector()
//injecter.cfgDel = "="
//injecter.cfgFile = "XXX/TrashCodes/TrashCodes.cfg"
//injecter.sourceFilesDir = "XXX"
//injecter.inject()
//injecter.removeInjection()

//localizations rename
let localizationRenamer = LocalizationRenamer()
localizationRenamer.searchDir = "XXX"
localizationRenamer.localizationDir = "XXX/Localization/Base.lproj"
localizationRenamer.rename()
