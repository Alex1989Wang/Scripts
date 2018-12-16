//
//  Console.swift
//  Renamer
//
//  Created by JiangWang on 2018/12/13.
//  Copyright © 2018 JiangWang. All rights reserved.
//

import Foundation

enum OutputType {
    case error
    case standard
}

class ConsoleIO {
    
    /// output a message to console
    ///
    /// - Parameters:
    ///   - message: messge content
    ///   - to: the type of message
    public func writeMessage(_ message: String, to: OutputType = .standard) {
        switch to {
        case .standard:
            print("\(message)")
        case .error:
            fputs("Error: \(message)\n", stderr)
        }
    }
    
    /// print the usage of this command line
    public func printUsage() {
        
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
        
        writeMessage("Usage:")
        writeMessage("\(executableName) -d DIR -pre PREFIX -proj_file PROJECT FILE")
        writeMessage("\(executableName) -h to show usage information")
        writeMessage("Type \(executableName) without an option to enter interactive mode.")
    }
    
    
    /// Get the input string from console
    ///
    /// - Returns: input content
    func getInput() -> String {
        // 1
        let keyboard = FileHandle.standardInput
        // 2
        let inputData = keyboard.availableData
        // 3
        let strData = String(data: inputData, encoding: String.Encoding.utf8)!
        // 4
        return strData.trimmingCharacters(in: CharacterSet.newlines)
    }
}

