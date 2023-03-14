//
//  AreasViewController.swift
//  AreaWatchDemo
//
//  Created by Simon Kim on 11/9/23.
//

import Foundation
import SwiftUI
import UIKit

protocol AreasViewModel: ObservableObject {
    var areas: [Area.Overview] { get }

    func send(_ action: Areas.Action)
}

struct AreasView<ViewModel: AreasViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    var body: some View {
        
        NavigationStack {
            VStack(alignment: .center) {
                List {
                    ForEach(viewModel.areas) { area in
                        FeatureArea(area: area)
                            .listRowSeparator(.hidden)
                            .onTapGesture {
                                viewModel.send(.onTapArea(area.id))
                            }
                    }
                }
                .listStyle(.grouped)
            }
            .navigationTitle("Areas")
        }
        .onAppear {
            viewModel.send(.onAppear)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    let viewModel = Areas.ViewModel(navigator: AreasNavigatorStub())
    let view = AreasView(
        viewModel: viewModel
    )
    
    viewModel.areas = [
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
    return UIHostingController(rootView: view)
}
