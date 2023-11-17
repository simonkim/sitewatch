//
//  SiteViewModelTests.swift
//  SiteWatchTests
//
//  Created by Simon Kim on 11/16/23.
//

import XCTest
import Combine
@testable import SiteWatch

final class SitesViewModelTests: XCTestCase {

    func testOnAppear_fetchSites_updateSiteImage() throws {
        let mockRemoteServer = MockRemoteServer()
        let viewModel = SitesViewModelImpl.mocked(remoteServer: mockRemoteServer)
        
        // .onAppear:
        // - RemoteServer.fetchSites()
        // - errorMessage == nil
        // - $siteDisplayContents x 3(initial empty, fetched sites, updated images x fetched sites)

        var site = Site.stubSamples[0]
        site.name = "UT1N"
        site.description = "UT1D"

        let exp1 = expectation(description: "fetchSites")
        mockRemoteServer.onFetch = {
            exp1.fulfill()
            return [site]
        }
        
        var cancellables: [AnyCancellable] = []
        
        let exp2 = viewModel.expectContentUpdate("contentUpdate", cancellables: &cancellables) { contents in
            // 0 -> 1 -> 1(image)
            if contents.count == 0 { return true }
            if contents.count == 1 {
                XCTAssertEqual(contents[0].poster.title, "UT1N")
                XCTAssertEqual(contents[0].poster.description, "UT1D")
                XCTAssertNotNil(contents[0].poster.image)
                return true
            }
            return false
        } configExp: {
            $0.expectedFulfillmentCount = 3
        }
        
        let exp3 = viewModel.expectErrorMessage("errorMessageNil", cancellables: &cancellables) {
            $0 == nil
        }
        
        viewModel.send(.onAppear)
        
        wait(for: [exp1, exp2, exp3], timeout: 1)
    }
    
    /// onAppear -> fetch fail -> errorMessage
    func testOnAppear_fetchSitesThrows_errorMessage() throws {
        let mockRemoteServer = MockRemoteServer()
        let viewModel = SitesViewModelImpl.mocked(remoteServer: mockRemoteServer)
        
        mockRemoteServer.onFetch = {
            throw NSError(domain: "Server error", code: 0, userInfo: nil)
        }
        
        var cancellables: [AnyCancellable] = []
        let expErrorMessage = viewModel.expectErrorMessage("errorMessage", cancellables: &cancellables) {
            $0 == SitesViewError.failedToLoadSites.localizedDescription
        }
        viewModel.send(.onAppear)

        wait(for: [expErrorMessage], timeout: 1)
    }
    
    /// onTapSite -> Navigator
    func testOnAppear_onTapSite_navigates() throws {
        var mockNavigator = MockNavigator()
        
        let expNavigate = expectation(description: "navigateToSiteDetail")
        var site = Site.stubSamples[0]
        site.id = "UT3ID"
        
        mockNavigator.onNavigateTo = {
            if case .siteDetail(let site) = $0, site.id == site.id { expNavigate.fulfill() }
        }
        
        let viewModel = SitesViewModelImpl.mocked(
            remoteServer: MockRemoteServer(),
            navigator: mockNavigator
        )
        viewModel.sites = [site]

        viewModel.send(.onTapSite(site.id))
        wait(for: [expNavigate], timeout: 1)
    }
    
}

extension SitesViewModelImpl {
    func expectContentUpdate(
        _ description: String,
        cancellables: inout [AnyCancellable],
        check: @escaping ([FeatureSiteDisplayContent]) -> Bool,
        configExp: (XCTestExpectation) -> Void = {_ in }) -> XCTestExpectation
    {
        let exp = XCTestExpectation(description: description)
        $siteDisplayContents
            .receive(on: RunLoop.main)
            .sink { contents in
                if check(contents) {
                    exp.fulfill()
                }
            }.store(in: &cancellables)
        configExp(exp)
        return exp
        
    }
    
    func expectErrorMessage(
        _ description: String,
        cancellables: inout [AnyCancellable],
        check: @escaping (String?) -> Bool,
        configExp: (XCTestExpectation) -> Void = {_ in }) -> XCTestExpectation
    {
        let exp = XCTestExpectation(description: description)
        $errorMessage
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink {
                if check($0) {
                    exp.fulfill()
                }
            }
            .store(in: &cancellables)
        configExp(exp)
        return exp
        
    }
}
