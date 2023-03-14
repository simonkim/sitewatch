//
//  AreasScene.swift
//  AreaWatchDemo
//
//  Created by Simon Kim on 11/8/23.
//

import Foundation
import Combine
import SwiftUI
import UIKit


struct AreasScene {
    let logger: AppLogger
    
    func viewController() -> UIViewController {
        
        let navigationController = UINavigationController()
        let navigator = Areas.Navigator(
            dependency: .init(
                logger: logger,
                navigationController: navigationController
            )
        )
        
        let viewModel = Areas.ViewModel(
            navigator: navigator
        )
        
        let view = AreasView(
            viewModel: viewModel
        )
        
        let viewController = UIHostingController(rootView: view)
        navigationController.pushViewController(viewController, animated: false)
        
        return navigationController
    }
}
