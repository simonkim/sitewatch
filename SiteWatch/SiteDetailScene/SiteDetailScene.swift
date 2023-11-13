//
//  SiteDetailScene.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/11/23.
//

import Foundation
import UIKit

struct SiteDetailScene {
    var site: Site
    
    func viewController() -> UIViewController {
        let viewController = SiteDetailViewController(
            viewModel: SiteDetailViewModelImpl(
                site: site
            )
        )
        return viewController
        
    }
}
