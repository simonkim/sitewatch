//
//  W52AppLogger.swift
//  Week52
//
//  Created by Simon Kim on 2023/09/16.
//

import Foundation

struct DemoAppLogger: AppLogger {
    func log(_ category: LogCategory, _ text: String) {
        print("\(category): \(text)")
    }
}
