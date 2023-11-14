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
        navigate(ToSiteDetail(site: site, events: dependency.remoteEvents, logger: logger))
    }
    
    private func navigate(_ envelope: SitesSceneNavigationEnvelope) {
        guard let navigationController = dependency.navigationController else {
            logger.log(.error, "\(type(of: self)): Missing UINavigationController")
            return
        }
        
        switch envelope {
        case let siteDetail as ToSiteDetail:
            siteDetail.present(navigationController: navigationController)
            
        default:
            logger.log("Unknown navigation Envelope type: \(envelope)")
        }
    }
}

protocol SitesSceneNavigationEnvelope {
    
}

struct ToSiteDetail: SitesSceneNavigationEnvelope {
    var site: Site
    var events: AnyPublisher<SiteEvent, Never>
    var logger: AppLogger
}

extension ToSiteDetail {
    
    /// Presents View Controller for SiteDetail by pushing to the navigation stack
    /// - Note When onDismiss = {} needs to be implemented,
    ///        catch viewWillDisappear() and
    ///        check self.isMovingFromParentViewController ||
    ///        self.isBeingDismissed in the pushed view controller
    /// - Parameter navigationController: New view controller is pushed to this
    func present(navigationController: UINavigationController) {
        let viewController = SiteDetailScene(
            site: site, 
            events: events,
            logger: logger
        ).viewController()

        navigationController.pushViewController(viewController, animated: true)
    }
}
