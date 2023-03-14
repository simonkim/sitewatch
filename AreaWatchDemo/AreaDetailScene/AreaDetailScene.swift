//
//  AreaDetailScene.swift
//  AreaWatchDemo
//
//  Created by Simon Kim on 11/11/23.
//

import Foundation
import UIKit

struct AreaDetailScene {
    
    func viewController() -> UIViewController {
        let viewController = AreaDetailViewController(viewModel: .init(
            items: [
                .init(
                    id: 0,
                    vital: Device.StatusViewModel(
                        coverImage: .sensorFill,
                        title: "Sensor",
                        // status: [...],
                        caption: "Updated 12:31 AM",
                        isStatusIconsBarVisible: true
                    ),
                    measurements: [
                        Device.StatusViewModel(
                            coverImage: .thermometer,
                            title: "22.3 " + .celcius,
                            // status: [...],
                            caption: "Warm",
                            isStatusIconsBarVisible: false
                        ),
                        Device.StatusViewModel(
                            coverImage: .humidity,
                            title: "65%",
                            // status: [...],
                            caption: "Above average",
                            isStatusIconsBarVisible: false
                        ),
                        Device.StatusViewModel(
                            coverImage: .noiseSensor,
                            title: "37 dB",
                            // status: [...],
                            caption: "Calm",
                            isStatusIconsBarVisible: false
                        ),
                    ]
                )
            ]))
        return viewController
        
    }
}
