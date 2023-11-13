//
//  CachedImageStore.swift
//  LoremPicsum
//
//  Created by Simon Kim on 11/12/23.
//
import UIKit

class CachedImageStore {
    enum Error: Swift.Error {
        case imageLoadingFailed
    }
    
    private let imageCache = NSCache<NSString, UIImage>()
    private var imageScale: CGFloat { UIScreen.main.scale }
    
    func getImage(from url: URL, targetSize: CGSize) async throws -> UIImage {
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            return cachedImage
        }

        guard let image = try await UIImage.load(from: url, targetThumbnailSize: targetSize, scale: imageScale) else {
            throw Error.imageLoadingFailed
        }
        imageCache.setObject(image, forKey: url.absoluteString as NSString)
        return image
    }
}

extension UIImage {
    /// Creates a thumbnail from the given data.
    ///
    /// - Parameters:
    ///   - data: The data representing the image.
    ///   - targetSize: The target size (in points) of the image to be displayed.
    ///   - scale: The scale factor to be applied when creating the thumbnail. Default is 1.0.
    /// - Throws: An error if the thumbnail cannot be created.
    convenience init(thumbnailFrom data: Data, targetSize: CGSize, scale: CGFloat = 1.0) throws {
        let options: [CFString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: max(targetSize.width * scale, targetSize.height * scale),
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true
        ]

        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            throw NSError(domain: "Thumbnail creation error", code: 0, userInfo: nil)
        }

        self.init(cgImage: thumbnail, scale: scale, orientation: .up)
    }
    
    static func load(from url: URL, targetThumbnailSize: CGSize? = nil, scale: CGFloat = 1.0) async throws -> UIImage? {

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let targetSize = targetThumbnailSize else {
                // Full size, no thumbnail
                return UIImage(data: data)
            }
            return try UIImage(thumbnailFrom: data, targetSize: targetSize, scale: scale)

        } catch {
            throw error
        }
    }
}
