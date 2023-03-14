//
//  URLDataStoreTests.swift
//  AreaWatchDemoTests
//
//  Created by Simon Kim on 2023/03/15.
//

import XCTest
import Combine

@testable import AreaWatchDemo

final class URLDataStoreTests: XCTestCase {

    func testQueryURL_URLEndpoint_url() throws {
        let url = URL(string: "https://whatever.com/path/to?cid=1234")!
        let endpoint = URLEndpoint(baseURL: url, queryItems: [])
        XCTAssertEqual(endpoint.url!, url)
    }
    
    func testURLEndpoint_areas_queryItem_page() throws {
        let endpoint = URLEndpoint.areas(page: 42)
        
        let request = endpoint.request()!
        XCTAssertEqual(request.httpMethod, "GET")
        let pageQueryItems = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
            .queryItems!.filter { $0.name == "page" }
        XCTAssertEqual(pageQueryItems.count, 1)
        XCTAssertEqual(pageQueryItems.first!.value, "42")
    }
    
    func testDataTaskPublisher() throws {
        let exp = expectation(description: "sink")

        let imageData = UIColor.lightGray.asImage(size: CGSize(width: 64, height: 64)).pngData()
        let mockSession = MockURLSession(data: imageData)
        let store = URLDataStore(mockSession)
        let c1 = store.dataTaskPublisher(.areas(page: nil))
            .assertNoFailure()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                exp.fulfill()
            }

        waitForExpectations(timeout: 0.5)
        
        c1.cancel()
    }
    
    func testURLImageStore_loadImagePublisher() throws {
        let exp = expectation(description: "sink")

        let imageURL = URL(string: "https://www.dzpubl.com/cdn/image0.jpg")
        let imageData = UIColor.lightGray.asImage(size: CGSize(width: 64, height: 64)).pngData()
        let mockSession = MockURLSession(data: imageData)
        let dataStore = URLDataStore(mockSession)
        let imageStore = URLImageStore(dataStore: dataStore)
        
        let c1 = imageStore.loadImagePublisher(for: imageURL!, size: nil)
            .assertNoFailure()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                exp.fulfill()
            }

        waitForExpectations(timeout: 0.5)
        
        c1.cancel()
    }
    
    func testURLImageStore_loadImagePublisher_unknownImageFormat() throws {
        let exp = expectation(description: "sink")

        let imageURL = URL(string: "https://www.dzpubl.com/cdn/image0.jpg")
        let imageData = "Unknown Image Format".data(using: .utf8)
        let mockSession = MockURLSession(data: imageData)
        let dataStore = URLDataStore(mockSession)
        let imageStore = URLImageStore(dataStore: dataStore)
        
        let c1 = imageStore.loadImagePublisher(for: imageURL!, size: nil)
            .receive(on: DispatchQueue.main)
            .sink { result in
                if case .failure(let error) = result,
                    case .unknownImageFormat = (error as? RemoteStoreError ) {
                    exp.fulfill()
                }
            } receiveValue: { _ in
            }

        waitForExpectations(timeout: 0.5)
        
        c1.cancel()
    }
}

struct MockURLSession: URLDataRequestable {

    var data: Data?

    func dataTaskPublisher(for request: URLRequest) -> AnyPublisher<Data, URLSession.DataTaskPublisher.Failure> {
        guard let data = data else {
            return Fail<Data, URLError>(error: URLError(URLError.badServerResponse))
                .eraseToAnyPublisher()
        }
        return Just(data)
            .setFailureType(to: URLSession.DataTaskPublisher.Failure.self)
            .eraseToAnyPublisher()
    }
}
