//
//  LocationsViewController.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/9/23.
//

import Foundation
import Combine
import SwiftUI


#Preview {
    FeatureSite(content: .stubSamples[0])
}

struct FeatureSite: View {
    var content: FeatureSiteDisplayContent

    var body: some View {
        VStack(alignment: .leading) {
            FeatureCard(poster: content.poster)
            StatusOverviewBar(deviceVitals: content.deviceVitals)
        }
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray, lineWidth: 0.5)
        )
        .padding(.all, 8)
    }
}

struct StatusOverviewBar: View {
    private var leading: [IndexedStatus]
    private var trailing: [IndexedStatus]
    
    var body: some View {
        HStack(alignment: .center, content: {
            ForEach(leading) {
                $0.status.deviceType.image(level: $0.status.level)
            }
            
            Spacer()
            
            ForEach(trailing) {
                $0.status.deviceType.image(level: $0.status.level)
            }
        })
        .padding(.horizontal)
        .padding(.vertical, 6)

    }
    private struct IndexedStatus: Identifiable {
        var id: Int
        var status: DeviceVital
    }
    
    init(deviceVitals: [DeviceVital]) {
        self.leading = Self.vitals(.leading, deviceVitals: deviceVitals)
            .enumerated()
            .map { .init(id: $0, status: $1)}
        self.trailing = Self.vitals(.trailing, deviceVitals: deviceVitals)
            .enumerated()
            .map { .init(id: $0, status: $1)}
    }

    static func vitals(_ alignment: Alignment, deviceVitals: [DeviceVital]) -> [DeviceVital] {
        switch alignment {
        case .leading:
            return deviceVitals.filter { $0.deviceType != .battery }
        case .trailing:
            fallthrough
        default:
            return deviceVitals.filter { $0.deviceType == .battery }
        }
    }
}
