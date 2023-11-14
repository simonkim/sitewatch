//
//  SiteDetailViewModel.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/13/23.
//

import Foundation
import Combine
import UIKit

class SiteDetailViewModelImpl: SiteDetailViewModel {
    typealias Item = DevicePanelViewModel
    var title: String
    var items: AnyPublisher<[SiteDetailItemChange], Never> {
        itemSubject.eraseToAnyPublisher()
    }
    
    private var site: Site
    private let logger: AppLogger
    private let measurementFormatter = MeasurementFormatter()

    private let itemSubject: CurrentValueSubject<[SiteDetailItemChange], Never> = .init([])
    private var cancellables: Set<AnyCancellable> = []

    init(site: Site, events: AnyPublisher<SiteEvent, Never>, logger: AppLogger) {
        self.site = site
        self.logger = logger
        self.title = site.name

        events
            .sink { [weak self] event in
                guard let self = self else { return }
                let updatedDevices = self.site.updatedDeviceIndices(with: event)

                if updatedDevices.count > 0 {
                    self.logger.log(.info, "\(event)")
                    updateView(with: self.site, updatedDevices: updatedDevices)
                }
            }
            .store(in: &cancellables)
    }
    
    func send(_ action: SiteDetailAction) {
        switch action {
        case .onAppear:
            updateView(with: site)
        }
    }
    
    private func updateView(with site: Site, updatedDevices: [Item.ID] = []) {
        let items = site.devices.enumerated().map { index, device in
            let change = SiteDetailItemChange(
                change: updatedDevices.isEmpty ? .add : (updatedDevices.contains(index) ? .update : .unchanged),
                item: Item(id: index,
                           vital: .init(panelCover: device, only: [.connectivity, .battery]),
                           measurements: device.measurements.map { .init(with: $0, formatter: measurementFormatter) })
            )
            return change
        }
        self.itemSubject.send(items)
    }
}

extension Site {
    
    mutating func updatedDeviceIndices(with event: SiteEvent) -> [Int] {
        switch event {
        case let e as MeasurementEvent:
            return update(measurement: e)
        case let e as VitalStatusEvent:
            return update(vital: e)

        default:                            // unsupported event
            return []
        }
    }
    
    /// Updates measurments of corresponding device and returns indices of updated devices
    mutating func update(measurement: MeasurementEvent) -> [Int] {
        guard let deviceIndex = devices.firstIndex(where: { device in
            device.id == measurement.deviceId
        }) else {
            return []
        }
        
        guard let measurementIndex = devices[deviceIndex].measurements.firstIndex(where: { $0.unit == measurement.measurement.unit}) else {
            return []
        }
        devices[deviceIndex].measurements[measurementIndex] = measurement.measurement
        return [deviceIndex]
    }
    
    mutating func update(vital: VitalStatusEvent) -> [Int] {
        guard let deviceIndex = devices.firstIndex(where: { device in
            device.id == vital.deviceId
        }) else {
            return []
        }
        
        guard let vitalIndex = devices[deviceIndex].vitals.firstIndex(where: { $0.deviceType == vital.deviceType}) else {
            return []
        }
        devices[deviceIndex].vitals[vitalIndex].level = vital.level
        return [deviceIndex]
    }
}

struct DevicePanelViewModel: Identifiable {
    var id: Int
    var vital: DeviceDetailStatusViewModel
    var measurements: [DeviceDetailStatusViewModel]
}

extension DevicePanelViewModel: Hashable {
    static func == (lhs: DevicePanelViewModel, rhs: DevicePanelViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct DeviceDetailStatusViewModel {
    var coverImage: UIImage? = nil
    var title: String
    var vitalStatus: [DeviceVital] = []
    var isStatusIconsBarVisible: Bool { !vitalStatus.isEmpty }
    var caption: String
    var coverImageURLString: String?
    
    init(coverImage: UIImage? = nil,
         title: String = "",
         caption: String = "",
         vitalStatus: [DeviceVital] = [],
         imageURLString: String? = nil
    ) {
        self.coverImage = coverImage
        self.title = title
        self.caption = caption
        self.vitalStatus = vitalStatus
        self.coverImageURLString = imageURLString
    }
}

extension DeviceDetailStatusViewModel {
    static let empty: Self = .init()
}

extension DeviceDetailStatusViewModel {
    init(panelCover device: SiteDevice, only types: [DeviceType]) {
        self.init(
            coverImage: device.photoImage ?? device.deviceType.coverUIImage(),
            title: device.name,
            caption: "Updated #when",     // TODO: `caption` displays when the last update to the statuc occured
            vitalStatus: device.vitals.filter { types.contains($0.deviceType) }
        )
    }
    
    init(with measurement: SensorMeasurement, formatter: MeasurementFormatter) {
        self.init(
            coverImage: measurement.coverImage,
            title: measurement.displayText(with: formatter),
            caption: measurement.displayCaption
        )
    }
}

extension SensorMeasurement {

    var coverImage: UIImage? {
        switch unit {
        case .temperature:  return UIImage.thermometer
        case .humidity:     return UIImage.humidity
        case .noise:        return UIImage.noiseSensor
        case .smoke:        return UIImage.smokeSensor
        }
    }
    
    func displayText(with formatter: MeasurementFormatter) -> String {
        switch unit {
        case .temperature:
            let measurement = Foundation.Measurement(value: self.measurement, unit: UnitTemperature.celsius)
            return formatter.string(from: measurement)
        case .humidity:
            return String(format: "%.1f", self.measurement) + " %"
        case .noise:
            return "\(Int(self.measurement)) dB"
        case .smoke:
            return String(format: "%.1f", self.measurement) + " % obs/ft"
        }
    }
    
    var displayCaption: String {
        switch unit {
        case .temperature:
            return "Fine"
        case .humidity:
            return "Fine"
        case .noise:
            return "Fine"
        case .smoke:
            return "Fine"
        }
    }

}
