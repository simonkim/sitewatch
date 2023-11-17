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

enum SitesViewError: Error {
    case failedToLoadSites
}

extension SitesViewError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .failedToLoadSites:
            return NSLocalizedString(
                "Failed to load sites", comment: "Failed to load sites from server"
            )
        }
    }
}

class SitesViewModelImpl: SitesViewModel {
    typealias Model = Site
    
    @Published var siteDisplayContents: [FeatureSiteDisplayContent] = []
    @Published var errorMessage: String?
    var sites: [Site] = []
    private var error: SitesViewError? {
        didSet {
            errorMessage = error?.localizedDescription ?? nil
        }
    }
    
    private let remoteServer: RemoteServer
    private let imageStore: ImageStore
    private let navigator: SitesNavigator
    private let logger: AppLogger
    
    private let featureImageTargetSize = CGSize(width: 400, height: 300)
    // Dispatch Queue of state update from Async tasks
    private let updateDq: DispatchQueue = .main
    
    init(remoteServer: RemoteServer, imageStore: ImageStore, logger: AppLogger, navigator: SitesNavigator) {
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
            navigator.navigate(to: .siteDetail(site))
        }
    }
    
    private func updateSiteDisplay(with fetchSites: @escaping () async throws -> [Model]) {
        error = nil
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
                updateDq.async {
                    self.error = .failedToLoadSites
                }
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

extension FeatureSiteDisplayContent {
    init(site: Site, placeholderImage: Image = .init(uiImage: .featureSitePlaceHolder)) {
        self.init(
            id: site.id,
            poster: .init(image: placeholderImage, title: site.name, description: site.description),
            deviceVitals: site.deviceVitals
        )
    }
}

private extension UIImage {
    static let featureSitePlaceHolder = UIColor.systemGray.asImage(size: CGSize(width: 64, height: 64))
}
