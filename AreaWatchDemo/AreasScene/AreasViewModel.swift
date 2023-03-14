//
//  AreasViewModel.swift
//  AreaWatchDemo
//
//  Created by Simon Kim on 11/11/23.
//

import Foundation
import Combine
import SwiftUI
import UIKit

enum Areas {

    enum Action {
        case onAppear
        case onTapArea(_ id: Area.Overview.ID)
    }
    
    class ViewModel: AreasViewModel {
        @Published var areas: [Area.Overview] = []
        let navigator: AreasNavigator
        
        init(navigator: AreasNavigator) {
            self.navigator = navigator
        }
        
        func send(_ action: Areas.Action) {
            switch action {
            case .onAppear:
                areas = Area.Overview.stubSamples

            case .onTapArea(let id):
                navigator.navigate(ToAreaDetail(areaId: id))

            }
        }
    }

}

// MARK: -

extension Area.Overview {
    static let stubSamples: [Area.Overview] = [
        .init(
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
        ),
        .init(
            poster: .init(
                image: Image("Cafe"),
                title: "Cafe",
                description: "Needs some rennovation"
            ),
            status: .init(
                devices: [
                    .init(device: .wifi, level: .low),
                    .init(device: .camera, level: .off),
                    .init(device: .sensor, level: .high),
                ]
            )
        )
    ]
}

