//
//  SitesScene.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/8/23.
//

import Foundation
import Combine
import SwiftUI
import UIKit

struct SitesScene {
    let remoteServer: RemoteServer
    let imageStore: CachedImageStore
    let logger: AppLogger
    
    func viewController() -> UIViewController {
        
        let navigationController = UINavigationController()
        let navigator = SitesNavigatorImpl(
            dependency: .init(
                logger: logger,
                remoteEvents: remoteServer.eventPublisher(),
                navigationController: navigationController
            )
        )
        
        let viewModel = SiteViewModelImpl(
            remoteServer: remoteServer,
            imageStore: imageStore,
            logger: logger,
            navigator: navigator
        )
        
        let view = SitesView(
            viewModel: viewModel
        )
        
        let viewController = UIHostingController(rootView: view)
        navigationController.pushViewController(viewController, animated: false)
        
        return navigationController
    }
}
