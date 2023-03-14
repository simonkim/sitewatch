//
//  URLImageStore.swift
//  DemoAreaWatch
//
//  Created by Simon Kim on 2023/04/23.
//

import UIKit
import Combine

extension URLEndpoint {
    static func image(url: URL) -> Self {
        URLEndpoint(baseURL: url, queryItems: [])
    }
}

struct URLImageStore: ImageStore {
    private var dataStore: RemoteDataStore
    
    init(dataStore: RemoteDataStore) {
        self.dataStore = dataStore
    }
    
    func loadImagePublisher(for url: URL, size: CGSize?) -> AnyPublisher<UIImage, Error> {
        dataStore.dataTaskPublisher(.image(url: url))
            .tryMap{ data in
                guard let image = UIImage(data: data) else {
                    throw RemoteStoreError.unknownImageFormat
                }
                return image
            }
            .eraseToAnyPublisher()
    }

}
