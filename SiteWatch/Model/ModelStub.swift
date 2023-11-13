//
//  ModelStub.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/12/23.
//

import Foundation
import SwiftUI

extension SiteDevice {
    static var stubDevice: Self { .stubConnectivity }
    
    static let stubConnectivity: Self = .init(
        id: "0",
        deviceType: .connectivity,
        vitals: [
            .init(deviceType: .connectivity, level: .high),
        ]
    )
    static let stubCamera: Self = .init(id: "1", deviceType: .camera)
    static let stubSensor: Self = .init(id: "2", deviceType: .sensor)
    static let stubBattery: Self = .init(id: "3", deviceType: .battery)
}

