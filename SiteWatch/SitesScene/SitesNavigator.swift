//
//  SitesNavigator.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/11/23.
//

import Foundation
import UIKit

protocol SitesNavigator {
    func navigate(_ envelope: SitesSceneNavigationEnvelope)
}

protocol SitesSceneNavigationEnvelope {
    
}

class SitesNavigatorImpl: SitesNavigator {
    struct Dependency {
        let logger: AppLogger
        weak var navigationController: UINavigationController?
    }
    
    private let dependency: Dependency
    private var logger: AppLogger { dependency.logger }
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func navigate(_ envelope: SitesSceneNavigationEnvelope) {
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

struct ToSiteDetail: SitesSceneNavigationEnvelope {
    var site: Site
}

extension ToSiteDetail {
    
    /// Presents View Controller for SiteDetail by pushing to the navigation stack
    /// - Note When onDismiss = {} needs to be implemented,
    ///        catch viewWillDisappear() and
    ///        check self.isMovingFromParentViewController ||
    ///        self.isBeingDismissed in the pushed view controller
    /// - Parameter navigationController: New view controller is pushed to this
    func present(navigationController: UINavigationController) {
        let viewController = SiteDetailScene(site: site).viewController()

        navigationController.pushViewController(viewController, animated: true)
    }
}
