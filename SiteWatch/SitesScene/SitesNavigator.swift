//
//  SitesNavigator.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/11/23.
//

import UIKit
import Combine

protocol SitesNavigator {
    func navigate(toSiteDetail site: Site)
}


class SitesNavigatorImpl: SitesNavigator {
    struct Dependency {
        let logger: AppLogger
        let remoteEvents: AnyPublisher<SiteEvent, Never>
        weak var navigationController: UINavigationController?
    }
    
    private let dependency: Dependency
    private var logger: AppLogger { dependency.logger }
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func navigate(toSiteDetail site: Site) {
        navigate(SiteDetailScene(site: site, events: dependency.remoteEvents, logger: logger))
    }
    
    private func navigate(_ envelope: SitesSceneNavigationEnvelope) {
        guard let navigationController = dependency.navigationController else {
            logger.log(.error, "\(type(of: self)): Missing UINavigationController")
            return
        }
        
        switch envelope {
        case let siteDetail as SiteDetailScene:
            navigationController.pushViewController(
                siteDetail.viewController(), animated: true
            )

        default:
            logger.log("Unknown navigation Envelope type: \(envelope)")
        }
    }
}

protocol SitesSceneNavigationEnvelope {
    func viewController() -> UIViewController
}

extension SiteDetailScene: SitesSceneNavigationEnvelope {}
