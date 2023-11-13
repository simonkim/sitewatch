//
//  AppLogger.swift
//  Week52
//
//  Created by Simon Kim on 2023/09/16.
//

import Foundation

enum LogCategory: String {
    case error = "Error"
    case warning = "Warning"
    case info = "Info"
    case debug = "Debug"
}

protocol AppLogger {
    func log(_ category: LogCategory, _ text: String)
}

extension AppLogger {
    func log(_ text: String) {
        log(.info, text)
    }
}
