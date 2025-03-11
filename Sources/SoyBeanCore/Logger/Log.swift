//
//  Logger.swift
//  SoyBean
//
//  Created by 구태호 on 3/11/25.
//

import OSLog


public enum Log {
    public static func info(
        fileID: StaticString = #fileID,
        line: UInt = #line,
        function: StaticString = #function,
        _ message: Any?
    ) {
        Log.log(level: .info, fileID: fileID, line: line, function: function, message: message)
    }
    
    public static func error(
        fileID: StaticString = #fileID,
        line: UInt = #line,
        function: StaticString = #function,
        _ message: Any?
    ) {
        Log.log(level: .error, fileID: fileID, line: line, function: function, message: message)
    }
    
    public static func debug(
        fileID: StaticString = #fileID,
        line: UInt = #line,
        function: StaticString = #function,
        _ message: Any?
    ) {
        Log.log(
            level: .debug,
            fileID: fileID,
            line: line,
            function: function,
            message: message
        )
    }
    
    public static func custom(
        category: String,
        level: OSLogType,
        fileID: StaticString = #fileID,
        line: UInt = #line,
        function: StaticString = #function,
        _ message: Any?
    ) {
        Log.log(
            category: category,
            level: level,
            fileID: fileID,
            line: line,
            function: function,
            message: message
        )
    }
    
    private static func log(
        category: String = "Context",
        level: OSLogType,
        fileID: StaticString,
        line: UInt,
        function: StaticString,
        message: Any?
    ) {
        #if DEBUG
        let subsystem = Bundle.main.bundleIdentifier!
        let logMessage = """
        fileID: \(fileID)
        line: \(line)
        function: \(function)
        
        \(message ?? "no message")
        """
        
        if #available(iOS 14.0, *) {
            let logger = Logger(subsystem: subsystem, category: category)
            logger.log(level: level, "\(logMessage, privacy: .public)")
            
        } else {
            let log = OSLog(subsystem: subsystem, category: category)
            os_log("%{public}@", log: log, type: level, logMessage)
        }
        #endif
    }
}

