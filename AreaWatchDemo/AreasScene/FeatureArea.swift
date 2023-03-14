//
//  LocationsViewController.swift
//  AreaWatchDemo
//
//  Created by Simon Kim on 11/9/23.
//

import Foundation
import Combine
import SwiftUI

struct FeatureArea: View {
    var area: Area.Overview

    var body: some View {
        VStack(alignment: .leading) {
            FeatureCard(poster: area.poster)
            StatusOverviewBar(status: area.status)
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
    var status: Area.Status
    var body: some View {
        HStack(alignment: .center, content: {
            ForEach(status.devices) { status in
                status.device.image(level: status.level)
            }
            
            Spacer()
            
            Image(systemName: "thermometer.medium")
            Text("18.6 \u{00B0}C")
                .font(.caption)
            Image(systemName: "ear.badge.waveform")
            Text("25 dB")
                .font(.caption)
            Image(systemName: "drop.degreesign")
            Text("65%")
                .font(.caption)

        })
        .padding(.horizontal)
        .padding(.bottom, 2)
    }
}

#Preview {
    FeatureArea(area: .init(
        poster: .init(
            image: Image("Pool"),
            title: "Pool",
            description: "Needs some rennovation"
        ),
        status: .init(
            devices: [
                .init(device: .wifi, level: .high),
                .init(device: .camera, level: .medium),
                .init(device: .sensor, level: .off),
            ]
        )
    ))
}
