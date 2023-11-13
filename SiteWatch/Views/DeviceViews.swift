//
//  DeviceViews.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/9/23.
//

import Foundation
import SwiftUI
import UIKit

extension String {
    static let celcius = "\u{00B0}C"
    static let fahrenheit = "\u{00B0}F"
}

extension DeviceType {
    func image(level: DeviceVitalLevel) -> some View {
        let attributes = viewAttribues(level: level)
        return Image(systemName: attributes.imageSystemName)
            .foregroundColor(attributes.style.color)
            .opacity(attributes.style.opacity)
    }

    private func viewAttribues(level: DeviceVitalLevel) -> ViewAttributes {
        let systemName: String
        switch self {
        case .connectivity:
            systemName = "wifi"
        case .camera:
            systemName = "web.camera"
        case .sensor:
            systemName = "sensor"
        case .battery:
            switch level {
            case .high:
                systemName = "battery.100percent"
            case .midhigh:
                systemName = "battery.75percent"
            case .medium:
                systemName = "battery.50percent"
            case .low:
                systemName = "battery.25percent"
            case .off:
                systemName = "battery.0percent"
            }
        }
        
        return .init(imageSystemName: systemName, style: level.style)
    }
    
    struct ViewAttributes {
        var imageSystemName: String
        var style: DeviceVitalLevel.Style = .init()
    }

}

extension DeviceVitalLevel {
    struct Style {
        var uiColor: UIColor = .green
        var opacity: Double = 1
        var color: Color { Color(uiColor: uiColor)}
    }
    
    var style: Style {
        switch self {
        case .high:
            return .init(uiColor: .systemGreen, opacity: 1)
        case .midhigh:
            return .init(uiColor: .systemBlue, opacity: 1)
        case .medium:
            return .init(uiColor: .systemOrange, opacity: 1)
        case .low:
            return .init(uiColor: .systemYellow, opacity: 1)
        case .off:
            return .init(uiColor: .systemGray, opacity: 0.3)
        }
    }
}

/// UIKit Extension
extension DeviceType {
    
    func uiImage(level: DeviceVitalLevel) -> UIImage? {
        let attributes = viewAttribues(level: level)
        return UIImage(systemName: attributes.imageSystemName)?
            .withTintColor(
                attributes.style.uiColor.withAlphaComponent(attributes.style.opacity),
                renderingMode: .alwaysOriginal
            )
    }
    
    // Alternative to photo
    func coverUIImage(level: DeviceVitalLevel = .off) -> UIImage? {
        let attributes = viewAttribues(level: level)
        return UIImage(systemName: attributes.imageSystemName)?
            .devicePanelCoverStyle
    }
    
}
extension UIImage {
    static var sensorFill: UIImage? {
        UIImage(systemName: "sensor.fill")?
            .measureIconStyle
    }
    static var thermometer: UIImage? {
        UIImage(systemName: "thermometer.medium")?
            .measureIconStyle
    }
    static var humidity: UIImage? {
        UIImage(systemName: "drop.degreesign")?
            .measureIconStyle
    }
    static var noiseSensor: UIImage? {
        UIImage(systemName: "ear.badge.waveform")?
            .measureIconStyle
    }
    static var smokeSensor: UIImage? {
        UIImage(systemName: "smoke")?
            .measureIconStyle
    }
    
    var measureIconStyle: UIImage {
        self.withTintColor(.gray, renderingMode: .alwaysOriginal)
    }
    
    var devicePanelCoverStyle: UIImage {
        self.withTintColor(.gray, renderingMode: .alwaysOriginal)
    }

}
