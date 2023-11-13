//
//  Models.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/9/23.
//

import Foundation
import SwiftUI
import UIKit

struct Site {
    var id: String
    var name: String
    var description: String
    var featureImageUrl: URL
    var devices: [SiteDevice]
    
    var deviceVitals: [DeviceVital] {
        return devices
            .flatMap { $0.vitals }
            .reduce(into: [:]) { (result, vital) in
                result[vital.deviceType] = vital.level
            }.map {
                DeviceVital(deviceType: $0.key, level: $0.value)
            }
    }
}

struct SiteDevice {
    var id: String
    var name: String = ""
    var photoImage: UIImage?
    var deviceType: DeviceType
    var vitals: [DeviceVital] = []
    var measurements: [SensorMeasurement] = []
}

struct DeviceVital {
    var deviceType: DeviceType
    var level: DeviceVitalLevel
}

enum DeviceType {
    case connectivity
    case camera
    case sensor
    case battery
}

enum DeviceVitalLevel: Int, CaseIterable {
    case high = 100
    case midhigh = 75
    case medium = 50
    case low = 25
    case off = 0
}

struct SensorMeasurement {
    var unit: SensorMeasurementUnit
    var measurement: Double
}

enum SensorMeasurementUnit {
    case temperature        // UnitTemperature/MeasurementFormatter
    case humidity           // percent
    case noise              // dB
    case smoke              // % obs/ft
}
