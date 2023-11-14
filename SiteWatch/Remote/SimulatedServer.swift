//
//  SimulatedServer.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/12/23.
//

import Foundation
import Combine

class SimulatedServer: RemoteServer {
    var eventSubject = PassthroughSubject<SiteEvent, Never>()
    var schedules: [SiteEventSchedule] = []
    var demoStartTime: Date = .now
    private let logger: AppLogger
    
    init(logger: AppLogger) {
        self.logger = logger
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.startDemo()
        }
    }
    
    func fetchSites() async throws -> [Site] {
        return Site.stubSamples
    }
    
    func eventPublisher() -> AnyPublisher<SiteEvent, Never> {
        return eventSubject
            .eraseToAnyPublisher()
    }
    
    private func startDemo() {
        self.schedules = demoSchedule.sorted(by: { $0.afterDelay < $1.afterDelay }).reversed()
        self.demoStartTime = .now
        logger.log(.info, "\(type(of:self)): Starting demo with \(self.schedules.count) events")
        DispatchQueue.main.async {
            self.runDemoStep()
        }
    }
    
    private func runDemoStep() {
        guard let schedule = schedules.popLast() else {
            startDemo()
            return
        }
        
        let dq = DispatchQueue.main
        
        let delay = Date.now.timeIntervalSince(demoStartTime).distance(to: schedule.afterDelay)
        logger.log(.info, "\(type(of:self)): Sending in " + String(format: "%.1f", delay) + "s \(schedule.event)")
        dq.asyncAfter(deadline: .now() + delay) {
            guard var event = schedule.event as? SiteEventTimeSerttable else {
                // wrong event, .timestamp change not allowed
                return
            }
            event.timestamp = .now
            self.eventSubject.send(event as! SiteEvent)
            dq.async { self.runDemoStep() }
        }

    }
}

struct SiteEventSchedule {
    var afterDelay: TimeInterval
    var event: SiteEvent
}

private let demoSchedule: [SiteEventSchedule] = [
    .init(afterDelay:  2, event: .sensor("pool-sensor", .temperature, 27)),
    .init(afterDelay:  5, event: .vital("pool-camera", .connectivity, .low)),
    .init(afterDelay: 14, event: .vital("pool-camera", .connectivity, .high)),
    .init(afterDelay:  5, event: .sensor("pool-sensor", .noise, 32)),
    .init(afterDelay: 10, event: .sensor("pool-sensor", .humidity, 32)),
    .init(afterDelay: 20, event: .sensor("pool-sensor", .noise, 34)),
    .init(afterDelay:  5, event: .vital("pool-sensor", .connectivity, .midhigh)),
    .init(afterDelay:  7, event: .vital("pool-sensor", .connectivity, .low)),
    .init(afterDelay: 10, event: .vital("pool-sensor", .connectivity, .high)),
    .init(afterDelay: 14, event: .vital("pool-sensor", .connectivity, .medium)),
    .init(afterDelay: 19, event: .vital("pool-sensor", .connectivity, .off)),
    .init(afterDelay: 22, event: .vital("pool-sensor", .connectivity, .midhigh)),
    .init(afterDelay: 27, event: .vital("pool-sensor", .connectivity, .high)),
    .init(afterDelay:  5, event: .vital("pool-sensor", .battery, .midhigh)),
    .init(afterDelay: 11, event: .vital("pool-sensor", .battery, .medium)),
    .init(afterDelay: 16, event: .vital("pool-sensor", .battery, .low)),
    .init(afterDelay: 23, event: .vital("pool-sensor", .battery, .off)),
    .init(afterDelay: 25, event: .vital("pool-sensor", .battery, .high)),

    .init(afterDelay:  5, event: .vital("cafe-sensor", .connectivity, .high)),
    .init(afterDelay:  6, event: .vital("cafe-sensor", .connectivity, .medium)),
    .init(afterDelay:  7, event: .vital("cafe-sensor", .connectivity, .midhigh)),
    .init(afterDelay: 14, event: .vital("cafe-sensor", .connectivity, .low)),
    .init(afterDelay: 15, event: .vital("cafe-sensor", .connectivity, .off)),
    .init(afterDelay: 20, event: .vital("cafe-sensor", .connectivity, .midhigh)),
    .init(afterDelay: 22, event: .vital("cafe-sensor", .connectivity, .high)),
    .init(afterDelay:  3, event: .sensor("cafe-sensor", .noise, 44)),
    .init(afterDelay:  8, event: .sensor("cafe-sensor", .noise, 32)),
    .init(afterDelay: 13, event: .sensor("cafe-sensor", .noise, 65)),
    .init(afterDelay: 15, event: .sensor("cafe-sensor", .noise, 69)),
    .init(afterDelay: 16, event: .sensor("cafe-sensor", .noise, 69)),
    .init(afterDelay: 17, event: .sensor("cafe-sensor", .noise, 72)),
    .init(afterDelay: 18, event: .sensor("cafe-sensor", .noise, 75)),
    .init(afterDelay: 19, event: .sensor("cafe-sensor", .noise, 78)),
    .init(afterDelay: 20, event: .sensor("cafe-sensor", .noise, 67)),
    .init(afterDelay: 21, event: .sensor("cafe-sensor", .noise, 51)),
    .init(afterDelay:  4, event: .sensor("cafe-sensor", .smoke, 0.21)),
    .init(afterDelay: 11, event: .sensor("cafe-sensor", .smoke, 0.37)),
    .init(afterDelay: 14, event: .sensor("cafe-sensor", .smoke, 0.19)),
    .init(afterDelay: 16, event: .sensor("cafe-sensor", .smoke, 0.20)),
    .init(afterDelay: 18, event: .sensor("cafe-sensor", .smoke, 0.11)),
    .init(afterDelay: 19.5, event: .sensor("cafe-sensor", .smoke, 0.4)),
]

private protocol SiteEventTimeSerttable {
    var timestamp: Date { get set }
}
extension MeasurementEvent: SiteEventTimeSerttable {}
extension VitalStatusEvent: SiteEventTimeSerttable {}

extension SiteEvent where Self == MeasurementEvent {
    static func sensor(_ deviceId: String, _ unit: SensorMeasurementUnit, _ measurement: Double) -> MeasurementEvent {
        MeasurementEvent(
            deviceId: deviceId,
            measurement: .init(unit: unit, measurement: measurement)
        )
    }
    
    static func vital(_ deviceId: String, _ deviceType: DeviceType, _ level: DeviceVitalLevel) -> VitalStatusEvent {
        VitalStatusEvent(
            deviceId: deviceId,
            deviceType: deviceType,
            level: level
        )
    }
}

struct VitalStatusEvent: SiteEvent {
    var timestamp: Date = .now
    var deviceId: String
    var deviceType: DeviceType
    var level: DeviceVitalLevel
}

struct MeasurementEvent: SiteEvent {
    var timestamp: Date = .now
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
