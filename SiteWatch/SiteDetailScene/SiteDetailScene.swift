//
//  SiteDetailScene.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/11/23.
//

import UIKit
import Combine

struct SiteDetailScene {
    var site: Site
    var events: AnyPublisher<SiteEvent, Never>
    var logger: AppLogger
    
    func viewController() -> UIViewController {
        let viewController = SiteDetailViewController(
            viewModel: SiteDetailViewModelImpl(
                site: site,
                events: events,
                logger: logger
            )
        )
        return viewController
        
    }
}
