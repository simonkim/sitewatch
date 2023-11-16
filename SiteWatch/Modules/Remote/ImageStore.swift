//
//  ImageStore.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/16/23.
//

import Foundation
import UIKit

enum ImageStoreError: Error {
    case imageLoadingFailed
}

protocol ImageStore {
    func getImage(from url: URL, targetSize: CGSize) async throws -> UIImage
}
