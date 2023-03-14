//
//  ImageStore.swift
//  DemoAreaWatch
//
//  Created by Simon Kim on 2023/04/23.
//

import UIKit
import Combine

protocol ImageStore {
    func loadImagePublisher(for url: URL, size: CGSize?) -> AnyPublisher<UIImage, Error>
}
