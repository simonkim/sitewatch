//
//  AreasTests.swift
//  AreaWatchDemoTests
//
//  Created by Simon Kim on 2023/03/14.
//

import XCTest
import Combine
@testable import AreaWatchDemo

final class AreasTests: XCTestCase {

    var subscriptions: [AnyCancellable] = []
    override func setUpWithError() throws {
        subscriptions = []
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadNextPage_moreAreas() throws {

        let expMoreAreas = expectation(description: "moreAreas")
        let expNotLoading = expectation(description: "footerState.notLoading")
        let expLoading = expectation(description: "footerState.loading")
        
        let mockDataStore = MockDataStore(
            preloadedResult: AreasQueryResult(
                items:[
                    .sample(title: "a", description: ["au"]),
                    .sample(title: "C", description: ["Cau"])
                ],
                nextPageToken: nil
            )
        )

        let sut = AreasInteractor(dataStore: mockDataStore)
        let viewModel = sut.viewModel
        
        viewModel.moreAreas.sink { areas in
            XCTAssertEqual(areas.items.count, 2)
            XCTAssertEqual(areas.nextPage, 0)
            expMoreAreas.fulfill()
        }.store(in: &subscriptions)
        
        viewModel.footerState.sink { state in
            if state.isLoading {
                expLoading.fulfill()
            } else if state.error == nil {
                expNotLoading.fulfill()
            }
        }.store(in: &subscriptions)

        sut.handle(.loadNextPage)

        waitForExpectations(timeout: 0.5)
    }
    
    func testLoadNexPage_loading_state_transitions() throws {
        
        // Setup
        let mockDataStore = MockDataStore()

        let interactor = AreasInteractor(dataStore: mockDataStore)
        let viewModel = interactor.viewModel
        
        // Assertions/Expectations
        let expRecoveredError = XCTestExpectation(description: "recovered")
        let expRecoveredLoaded = XCTestExpectation(description: "expRecoveredLoaded")
        viewModel.footerState.sink { state in
            print("sink: \(state)")
            if state.isLoading {
                expRecoveredError.fulfill()
            }
            if !state.isLoading {
                expRecoveredLoaded.fulfill()
            }
        }.store(in: &subscriptions)

        // Execute:
        interactor.handle(.loadNextPage)

        wait(for: [expRecoveredError, expRecoveredLoaded], timeout: 0.5)

    }
    
    func testLoadNexPage_fail_footerStateError() throws {
        let expError = expectation(description: "error")
        
        let mockDataStore = MockDataStore(
            throwError: URLDataStore.Error.invalidURL
        )

        let sut = AreasInteractor(dataStore: mockDataStore)
        let viewModel = sut.viewModel
        
        viewModel.moreAreas.sink { _ in
            XCTFail("moreAreas should not occure")
        }.store(in: &subscriptions)
        
        viewModel.updatedCoverImage.sink { _ in
            XCTFail("updatedCoverImage should not occure")
        }.store(in: &subscriptions)

        var isLoading = true
        viewModel.footerState.sink { state in
            isLoading = state.isLoading
            if state.error != nil {
                expError.fulfill()
            }

        }.store(in: &subscriptions)
        
        sut.handle(.loadNextPage)

        waitForExpectations(timeout: 50)
        
        XCTAssertFalse(isLoading)

    }
    
    func testLoadNexPage_after_fail_recovers() throws {
        
        var eventsToPublish: [MockDataStore.Event] = [
            .error(URLDataStore.Error.invalidURL),
            .result(.init(items: [], nextPageToken: nil))
        ]
        // Setup
        let mockDataStore = MockDataStore(
            nextEvent: {
                return eventsToPublish.removeFirst()
            }
        )

        let interactor = AreasInteractor(dataStore: mockDataStore)
        let viewModel = interactor.viewModel
        
        // Assertions/Expectations
        let expError = expectation(description: "error")

        var isLoading = true
        let c1 = viewModel.footerState.sink { state in
            print("sink1: \(state)")
            isLoading = state.isLoading
            if state.error != nil {
                expError.fulfill()
            }

        }
        
        // Execute 1: Error
        interactor.handle(.loadNextPage)

        waitForExpectations(timeout: 0.5)
        XCTAssertFalse(isLoading)
        c1.cancel()
        
        // Execute 2: Recovered, but another error
        let expRecoveredError = XCTestExpectation(description: "recovered")
        let expRecoveredLoaded = XCTestExpectation(description: "expRecoveredLoaded")
        viewModel.footerState.sink { state in
            print("sink2: \(state)")
            if state.isLoading {
                expRecoveredError.fulfill()
            }
            if !state.isLoading && state.error == nil {
                expRecoveredLoaded.fulfill()
            }
        }.store(in: &subscriptions)
        
        interactor.handle(.loadNextPage)

        wait(for: [expRecoveredError, expRecoveredLoaded], timeout: 0.5)
    }
    
    func testFooterStateEquality() throws {
        
        XCTAssertEqual(LoadingState.loading, LoadingState.loading)
        XCTAssertEqual(LoadingState.finished(nil), LoadingState.finished(nil))
        XCTAssertNotEqual(LoadingState.loading, LoadingState.finished(nil))
        XCTAssertEqual(LoadingState.finished(Areas.RemoteStoreError.invalidURL), LoadingState.finished(Areas.RemoteStoreError.invalidURL))
        XCTAssertNotEqual(LoadingState.finished(Areas.RemoteStoreError.invalidURL), LoadingState.finished(nil))
    }
}

struct MockDataStore: AreasDataStore {

    enum Event {
        case result(AreasQueryResult)
        case error(RemoteStoreError)
    }
    
    var preloadedResult: AreasQueryResult = .init(items: [], nextPageToken: nil)
    var throwError: Areas.RemoteStoreError? = nil
    var nextEvent: (() -> Event?)? = nil

    func areasPublisher(page: Int?) -> AnyPublisher<Areas.AreasQueryResult, Areas.RemoteStoreError> {
        print("page: \(page ?? 0)")
        if let event = nextEvent?() {
            return publisher(event: event)
        }
        if let error = throwError {
            return publisher(event: .error(error))
        }
        
        return publisher(event: .result(preloadedResult))
    }
    
    func publisher(event: Event) -> AnyPublisher<Areas.AreasQueryResult, Areas.RemoteStoreError>  {
        switch event {
        case .result(let queryResult):
            return Just<Areas.AreasQueryResult>(queryResult)
                .setFailureType(to: Areas.RemoteStoreError.self)
                .eraseToAnyPublisher()
        case .error(let e):
            return Fail<Areas.AreasQueryResult, Areas.RemoteStoreError>(error: e)
                .eraseToAnyPublisher()
            
        }
    }
}



// Test setup silencer
struct MockImageStore: ImageStore {
    func load(url: URL, size: CGSize?) async throws -> UIImage {
        throw RemoteStoreError.unknownImageFormat
    }
    
    func loadImagePublisher(for url: URL, size: CGSize?) -> AnyPublisher<UIImage, Error> {
        Fail(error: RemoteStoreError.unknownImageFormat)
            .eraseToAnyPublisher()
    }

}
