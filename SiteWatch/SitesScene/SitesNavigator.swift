//
//  SitesNavigator.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/11/23.
//

import UIKit
import Combine

enum SitesNavigationTarget {
    case siteDetail(Site)
}

protocol SitesNavigator {
    func navigate(to target: SitesNavigationTarget)
}

protocol UIKitNavigatable: AnyObject {
    func pushViewController(_ viewController: UIViewController, animated: Bool)
}

extension UINavigationController: UIKitNavigatable {
}


class SitesNavigatorImpl: SitesNavigator {
    struct Dependency {
        let logger: AppLogger
        let remoteEvents: AnyPublisher<SiteEvent, Never>
        weak var navigationController: UIKitNavigatable?
    }
    
    private let dependency: Dependency
    private var logger: AppLogger { dependency.logger }
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func navigate(to target: SitesNavigationTarget) {
        guard let navigationController = dependency.navigationController else {
            logger.log(.error, "\(type(of: self)): Missing UINavigationController")
            return
        }
        
        switch target {
        case .siteDetail(let site):
            let scene = SiteDetailScene(site: site, events: dependency.remoteEvents, logger: logger)
            navigationController.pushViewController( scene.viewController(), animated: true)
        }
    }
}
