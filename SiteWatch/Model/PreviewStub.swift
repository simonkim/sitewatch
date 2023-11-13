//
//  PreviewStub.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/14/23.
//

import Foundation
import SwiftUI

extension FeatureSiteDisplayContent {
    static let stubSamples: [FeatureSiteDisplayContent] = [
        .init(
            id: "0",
            poster: .init(
                image: Image("Pool"),
                title: "Pool",
                description: "Needs some rennovation"
            ),
            deviceVitals: [
                .init(deviceType: .connectivity, level: .high),
                .init(deviceType: .camera, level: .medium),
                .init(deviceType: .sensor, level: .off),
                .init(deviceType: .battery, level: .low),
            ]

        ),
        .init(
            id: "1",
            poster: .init(
                image: Image("Cafe"),
                title: "Cafe",
                description: "Needs some rennovation"
            ),
            deviceVitals: [
                .init(deviceType: .connectivity, level: .low),
                .init(deviceType: .camera, level: .off),
                .init(deviceType: .sensor, level: .high),
            ]
        )
    ]
}

extension DevicePanelViewModel {
    static let stubSamples: [Self] = [
        .init(
            id: 0,
            vital: DeviceDetailStatusViewModel(
                coverImage: .sensorFill,
                title: "Sensor",
                // status: [...],
                caption: "Updated 12:31 AM",
                vitalStatus: [.init(deviceType: .connectivity, level: .high)]
            ),
            measurements: [
                .stubThermometer,
                .stubHumidity,
                .stubNoise,
            ]
        )
    ]
}

extension DeviceDetailStatusViewModel {
    static let stubThermometer: Self = .init(
        coverImage: .thermometer,
        title: "22.3 " + .celcius,
        // status: [...],
        caption: "Warm"
    )
    
    static let stubHumidity: Self = .init(
        coverImage: .humidity,
        title: "65%",
        // status: [...],
        caption: "Above average"
    )
    static let stubNoise: Self = .init(
        coverImage: .noiseSensor,
        title: "37 dB",
        // status: [...],
        caption: "Calm"
    )
}

