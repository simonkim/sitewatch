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
    var items: AnyPublisher<[Item], Never> {
        itemSubject.eraseToAnyPublisher()
    }
    
    private var site: Site
    private let itemSubject: CurrentValueSubject<[Item], Never> = .init([])
    private let measurementFormatter = MeasurementFormatter()

    init(site: Site) {
        self.site = site
    }
    
    func send(_ action: SiteDetailAction) {
        switch action {
        case .onAppear:
            let items = site.devices.enumerated().map { index, device in
                Item(id: index,
                     vital: .init(panelCover: device, only: [.connectivity, .battery]),
                     measurements: device.measurements.map { .init(with: $0, formatter: measurementFormatter) })
            }
            self.itemSubject.send(items)
        }
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
            caption: "Updated #when",
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
