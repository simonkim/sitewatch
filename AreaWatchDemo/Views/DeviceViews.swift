//
//  DeviceViews.swift
//  AreaWatchDemo
//
//  Created by Simon Kim on 11/9/23.
//

import Foundation
import SwiftUI


extension String {
    static let celcius = "\u{00B0}C"
    static let fahrenheit = "\u{00B0}F"
}

extension Device.Kind {
    func image(level: Device.Level) -> some View {
        let attributes = viewAttribues(level: level)
        return Image(systemName: attributes.imageSystemName)
            .foregroundColor(attributes.style.color)
            .opacity(attributes.style.opacity)
    }
    
    private func viewAttribues(level: Device.Level) -> Device.ViewAttributes {
        let systemName: String
        switch self {
        case .wifi:
            systemName = "wifi"
        case .camera:
            systemName = "web.camera"
        case .sensor:
            systemName = "sensor"
        case .battery:
            switch level {
            case .high:
                systemName = "battery.100percent"
            case .medium:
                systemName = "battery.75percent"
            case .low:
                systemName = "battery.25percent"
            case .off:
                systemName = "battery.0percent"
            }
        }
        
        return .init(imageSystemName: systemName, style: level.style)
    }
    
}

private extension Device {
    struct ViewAttributes {
        var imageSystemName: String
        var style: Device.Level.Style = .init()
    }
}

private extension Device.Level {
    struct Style {
        var color: Color = .green
        var opacity: Double = 1
    }
    
    var style: Style {
        switch self {
        case .high:
            return .init(color: .green, opacity: 1)
        case .medium:
            return .init(color: .blue, opacity: 1)
        case .low:
            return .init(color: .orange, opacity: 1)
        case .off:
            return .init(color: Color(uiColor:.gray), opacity: 0.3)
        }
    }
}
