//
//  URLDataStore.swift
//  DemoAreaWatch
//
//  Created by Simon Kim on 2023/04/23.
//

import Foundation
import Combine

extension URLSession: URLDataRequestable {
    func dataTaskPublisher(for request: URLRequest) -> AnyPublisher<Data, URLSession.DataTaskPublisher.Failure> {
        return self.dataTaskPublisher(for: request)
            .map(\.data)
            .eraseToAnyPublisher()
    }
}

struct URLDataStore: RemoteDataStore {
    typealias Error = RemoteStoreError
    
    private let urlSession: URLDataRequestable
    
    init(_ urlSession: URLDataRequestable = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func dataTaskPublisher(_ endPoint: URLEndpoint) -> AnyPublisher<Data, RemoteStoreError> {
        guard let request = endPoint.request() else {
            return Fail(error: Error.invalidURL).eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: request)
            .mapError { Error.network($0) }
            .eraseToAnyPublisher()
    }

}

/// Mockable URLSession for unit test setup
protocol URLDataRequestable {
    func dataTaskPublisher(for request: URLRequest) -> AnyPublisher<Data, URLSession.DataTaskPublisher.Failure>
}
