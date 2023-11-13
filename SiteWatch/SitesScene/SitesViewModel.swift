//
//  SitesViewModel.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/11/23.
//

import Foundation
import Combine
import SwiftUI
import UIKit

enum SiteAction {
    case onAppear
    case onTapSite(_ id: FeatureSiteDisplayContent.ID)
}

class SiteViewModelImpl: SitesViewModel {
    typealias Model = Site
    
    @Published var siteDisplayContents: [FeatureSiteDisplayContent] = []
    private var sites: [Site] = []
    
    private let remoteServer: RemoteServer
    private let imageStore: CachedImageStore
    private let navigator: SitesNavigator
    private var errorMessage = PassthroughSubject<String, Never>()
    private let logger: AppLogger
    
    private let featureImageTargetSize = CGSize(width: 400, height: 300)
    // Dispatch Queue of state update from Async tasks
    private let updateDq: DispatchQueue = .main
    
    init(remoteServer: RemoteServer, imageStore: CachedImageStore, logger: AppLogger, navigator: SitesNavigator) {
        self.remoteServer = remoteServer
        self.imageStore = imageStore
        self.logger = logger
        self.navigator = navigator
    }
    
    func send(_ action: SiteAction) {
        switch action {
        case .onAppear:
            updateSiteDisplay(with: remoteServer.fetchSites)

        case .onTapSite(let id):
            guard let site = sites.first(where: { $0.id == id }) else {
                logger.log(.error, "Site not found by id \(id)")
                return
            }
            navigator.navigate(ToSiteDetail(site: site))
        }
    }
    
    private func updateSiteDisplay(with fetchSites: @escaping () async throws -> [Model]) {
        Task {
            do {
                let sites = try await fetchSites()
                updateDq.async {
                    self.sites = sites
                    self.siteDisplayContents = sites.map { FeatureSiteDisplayContent(site: $0) }
                }
                for site in sites {
                    let image = try await imageStore.getImage(from: site.featureImageUrl, targetSize: featureImageTargetSize)
                    setSite(id: site.id, image: image)
                }
            } catch {
                errorMessage.send("Failed to fetch Sites")
            }
        }
    }
    
    private func setSite(id: FeatureSiteDisplayContent.ID, image: UIImage) {
        updateDq.async {
            if let i = self.siteDisplayContents.firstIndex(where: { $0.id == id}) {
                self.siteDisplayContents[i].poster.image = Image(uiImage: image)
            }
        }
    }
}
