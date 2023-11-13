//
//  DevicePanel.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/9/23.
//

import Foundation
import SwiftUI

struct DevicePanel: View {
    var body: some View {

        HStack(alignment: .top) {
            DeviceStatusView()
            Divider()
                .scaleEffect(CGSize(width: 1.0, height: 0.7))
            Measurements()
        }
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(uiColor: .systemGray5), lineWidth: 0.5)
        )
        .padding(.vertical, 4)
    }
}

struct DeviceStatusView: View {

    var body: some View {
        VStack {
            Image(systemName: "sensor")
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .scaleEffect(CGSize(width: 0.7, height: 0.7))
                .padding()

            Text("Enterance")
                .font(.title2)
                .bold()

            VStack {
                HStack {
                    DeviceType.connectivity.image(level: .high)
                    DeviceType.battery.image(level: .off)
                }
                .padding(.vertical, 4)
                Text("11:24 PM")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct Measurements: View {
    var body: some View {
        Grid {
            GridRow {
                Measurement()
                Measurement()
            }
            GridRow {
                Measurement()
                Measurement()
            }
        }
        .padding()
    }
}

struct Measurement: View {
    var body: some View {
        VStack {
            Image(systemName: "thermometer.medium")
                .font(.largeTitle)

            Text("18.6 \u{00B0}C")
                .font(.caption)
        }
        .frame(minWidth: 50)
        .padding()
    }
}

#Preview {
    List {
        ForEach(0..<3) { _ in
            DevicePanel()
                .listRowSeparator(.hidden)
                .listRowBackground(Color(uiColor:.systemGray6))
        }
    }
    .listStyle(.inset)


}
