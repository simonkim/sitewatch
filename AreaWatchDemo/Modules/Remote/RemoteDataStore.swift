//
//  RemoteDataStore.swift
//  DemoAreaWatch
//
//  Created by Simon Kim on 2023/03/14.
//

import UIKit
import Combine

enum RemoteStoreError: Swift.Error {
    case invalidURL
    case unknownImageFormat
    case decodingFailure(Swift.Error)
    case network(Swift.Error?)
}

struct URLEndpoint {
    let baseURL: URL
    let queryItems: [URLQueryItem]
    
    var url: URL? {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.queryItems = (components.queryItems ?? []) + queryItems
        return components.url
    }
    
    func request() -> URLRequest? {
        return url.map { URLRequest(url: $0) }
    }
}

protocol RemoteDataStore {
    func dataTaskPublisher(_ endPoint: URLEndpoint) -> AnyPublisher<Data, RemoteStoreError>
}

extension RemoteDataStore {
    func dataPublisher<T: Decodable>(_ endPoint: URLEndpoint) -> AnyPublisher<T, RemoteStoreError> {
        return dataTaskPublisher(endPoint)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { RemoteStoreError.decodingFailure($0) }
            .eraseToAnyPublisher()
    }
}
