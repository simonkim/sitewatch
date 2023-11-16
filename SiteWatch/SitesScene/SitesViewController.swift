//
//  SitesViewController.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/9/23.
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 17.0, *)
#Preview {
    let logger = DemoAppLogger()
    let viewModel = SitesViewModelImpl(
        remoteServer: SimulatedServer(logger: logger),
        imageStore: CachedImageStore(),
        logger: logger,
        navigator: SitesNavigatorStub()
    )
    let view = SitesView(
        viewModel: viewModel
    )
    
    viewModel.siteDisplayContents = FeatureSiteDisplayContent.stubSamples
    return UIHostingController(rootView: view)
}

protocol SitesViewModel: ObservableObject {
    var siteDisplayContents: [FeatureSiteDisplayContent] { get }
    var errorMessage: String? { get }

    func send(_ action: SiteAction)
}

struct FeatureSiteDisplayContent: Identifiable {
    var id: String
    var poster: FeaturePoster
    var deviceVitals: [DeviceVital]
    
    init(id: String, poster: FeaturePoster, deviceVitals: [DeviceVital]) {
        self.id = id
        self.poster = poster
        self.deviceVitals = deviceVitals
    }
}

struct SitesView<ViewModel: SitesViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    var body: some View {
        
        NavigationStack {
            VStack(alignment: .center) {
                List {
                    ForEach(viewModel.siteDisplayContents) { site in
                        FeatureSite(content: site)
                            .listRowSeparator(.hidden)
                            .onTapGesture {
                                viewModel.send(.onTapSite(site.id))
                            }
                    }
                }
                .listStyle(.grouped)
            }
            .navigationTitle("Sites")
        }
        .onAppear {
            viewModel.send(.onAppear)
        }
    }
}

extension UIColor {
    func asImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            self.setFill()
            context.fill(.init(x: 0, y: 0, width: size.width, height: size.height))
        }
    }
}
