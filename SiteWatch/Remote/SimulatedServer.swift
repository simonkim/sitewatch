//
//  SimulatedServer.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/12/23.
//

import Foundation
import Combine

class SimulatedServer: RemoteServer {
    func fetchSites() async throws -> [Site] {
        return Site.stubSamples
    }
    
    func eventPublisher() -> AnyPublisher<SiteEvent, Never> {
        return Just(VitalStatusEvent(device: .stubDevice, level: .medium))
            .eraseToAnyPublisher()
    }
}

struct VitalStatusEvent: SiteEvent {
    var device: SiteDevice
    var level: DeviceVitalLevel

    var deviceId: String { device.id }
    var deviceType: DeviceType { device.deviceType }
}

struct MeasurementEvent: SiteEvent {
    var deviceId: String
    var measurement: SensorMeasurement
}

extension Site {
    static let stubSamples: [Self] = [
        .init(
            id: "0",
            name: "Pool",
            description: "Needs some rennovation",
            featureImageUrl: URL(string: "https://picsum.photos/id/11/2500/1667")!,
            devices: [
                .init(
                    id: "pool-sensor",
                    name: "Noise Sensor",
                    deviceType: .sensor,
                    vitals: [
                        .init(deviceType: .connectivity, level: .midhigh),
                        .init(deviceType: .battery, level: .high),
                    ],
                    measurements: [
                        .init(unit: .noise, measurement: 43),
                        .init(unit: .temperature, measurement: 32),
                        .init(unit: .humidity, measurement: 21),
                    ]
                ),
                .init(
                    id: "pool-camera",
                    name: "Camera",
                    deviceType: .camera,
                    vitals: [
                        .init(deviceType: .connectivity, level: .low),
                        .init(deviceType: .camera, level: .midhigh),
                        .init(deviceType: .battery, level: .medium),
                    ]
                ),

            ]

        ),
        .init(
            id: "1",
            name: "Cafe",
            description: "Needs some rennovation",
            featureImageUrl: URL(string: "https://picsum.photos/id/21/3008/2008")!,
            devices: [
                .init(
                    id: "cafe-sensor",
                    name: "Sensor",
                    deviceType: .sensor,
                    vitals: [
                        .init(deviceType: .connectivity, level: .midhigh),
                        .init(deviceType: .battery, level: .high),
                    ],
                    measurements: [
                        .init(unit: .smoke, measurement: 0.12),
                        .init(unit: .noise, measurement: 51),

                    ]
                ),

            ]
        )
    ]
}
