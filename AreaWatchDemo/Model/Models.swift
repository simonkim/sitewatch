//
//  Models.swift
//  AreaWatchDemo
//
//  Created by Simon Kim on 11/9/23.
//

import Foundation
import UIKit

enum Area {

    struct Overview: Identifiable {
        let id = UUID()
        let poster: FeaturePoster
        let status: Status
    }
    
    struct Status {
        var devices: [Device.Status] = []
    }
    
}

enum Device {
    struct Status: Identifiable {
        var id = UUID()
        var device: Kind
        var level: Level
    }
    
    enum Level {
        case high
        case medium
        case low
        case off
    }

    enum Kind {
        case wifi
        case camera
        case sensor
        case battery
    }
    
    struct PanelViewModel: Identifiable {
        var id: Int
        var vital: StatusViewModel
        var measurements: [StatusViewModel]
    }
    
    struct StatusViewModel {
        var coverImage: UIImage? = nil
        var title: String
        var isStatusIconsBarVisible: Bool
        var caption: String
        var coverImageURLString: String?
        
        init(coverImage: UIImage? = nil,
             title: String = "",
             caption: String = "",
             isStatusIconsBarVisible: Bool = false,
             imageURLString: String? = nil
        ) {
            self.coverImage = coverImage
            self.title = title
            self.caption = caption
            self.isStatusIconsBarVisible = isStatusIconsBarVisible
            self.coverImageURLString = imageURLString
        }
    }
}

extension Device.StatusViewModel {
    static let empty: Self = .init()

}
