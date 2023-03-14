//
//  AreasNavigator.swift
//  AreaWatchDemo
//
//  Created by Simon Kim on 11/11/23.
//

import Foundation
import UIKit

protocol AreasNavigator {
    func navigate(_ envelope: AreasSceneNavigationEnvelope)
}

protocol AreasSceneNavigationEnvelope {
    
}

/// Stub implementation for Preview, does nothing
struct AreasNavigatorStub: AreasNavigator {
    func navigate(_ envelope: AreasSceneNavigationEnvelope) {
        
    }
}

extension Areas {
    class Navigator: AreasNavigator {
        struct Dependency {
            let logger: AppLogger
            weak var navigationController: UINavigationController?
        }
        
        private let dependency: Dependency
        private var logger: AppLogger { dependency.logger }
        
        init(dependency: Dependency) {
            self.dependency = dependency
        }
        
        func navigate(_ envelope: AreasSceneNavigationEnvelope) {
            guard let navigationController = dependency.navigationController else {
                logger.log(.error, "\(type(of: self)): Missing UINavigationController")
                return
            }
            
            switch envelope {
            case let areaDetail as ToAreaDetail:
                areaDetail.present(navigationController: navigationController)
                
            default:
                logger.log("Unknown navigation Envelope type: \(envelope)")
            }
        }

    }
}

struct ToAreaDetail: AreasSceneNavigationEnvelope {
    var areaId: Area.Overview.ID
}

extension ToAreaDetail {
    
    /// Presents View Controller for AreaDetail by pushing to the navigation stack
    /// - Note When onDismiss = {} needs to be implemented,
    ///        catch viewWillDisappear() and
    ///        check self.isMovingFromParentViewController ||
    ///        self.isBeingDismissed in the pushed view controller
    /// - Parameter navigationController: New view controller is pushed to this
    func present(navigationController: UINavigationController) {
        let viewController = AreaDetailScene().viewController()

        navigationController.pushViewController(viewController, animated: true)
    }
}
