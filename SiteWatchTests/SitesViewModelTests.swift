//
//  SiteViewModelTests.swift
//  SiteWatchTests
//
//  Created by Simon Kim on 11/16/23.
//

import XCTest
import Combine
@testable import SiteWatch



/// Input:
/// - onAppear
/// - onTapSite
/// Output:
/// - RemoteServer.fetchSites()
/// - siteDisplayContents
/// - Navigator(toSiteDetail:)
final class SitesViewModelTests: XCTestCase {

    func testOnAppear_fetchSites_updateSiteImage() throws {
        let mockRemoteServer = MockRemoteServer()
        let viewModel = SitesViewModelImpl.mocked(remoteServer: mockRemoteServer)
        
        // .onAppear:
        // - RemoteServer.fetchSites()
        // - errorMessage == nil
        // - $siteDisplayContents x 3(initial empty, fetched sites, updated images x fetched sites)
        let expFetchSites = expectation(description: "fetchSites")
        let expErrorMessageNil = expectation(description: "errorMessageNil")
        let expContentUpdate = expectation(description: "contentUpdate")
        expContentUpdate.expectedFulfillmentCount = 3

        var site = Site.stubSamples[0]
        site.name = "UT1N"
        site.description = "UT1D"

        mockRemoteServer.onFetch = {
            expFetchSites.fulfill()
            return [site]
        }
        
        var cancellables: [AnyCancellable] = []
        viewModel.$siteDisplayContents
            .receive(on: RunLoop.main)
            .sink { contents in
                // 0 -> 1 -> 1(image)
                if contents.count == 0 {
                    expContentUpdate.fulfill()
                    return
                }
                if contents.count == 1 {
                    expContentUpdate.fulfill()
                    XCTAssertEqual(contents[0].poster.title, "UT1N")
                    XCTAssertEqual(contents[0].poster.description, "UT1D")
                    XCTAssertNotNil(contents[0].poster.image)
                }
            }.store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink{  if $0 == nil { expErrorMessageNil.fulfill() } }
            .store(in: &cancellables)
        
        viewModel.send(.onAppear)
        
        wait(for: [expFetchSites, expContentUpdate, expErrorMessageNil], timeout: 1)
    }
    
    /// onAppear -> fetch fail -> errorMessage
    func testOnAppear_fetchSitesThrows_errorMessage() throws {
        let mockRemoteServer = MockRemoteServer()
        let viewModel = SitesViewModelImpl.mocked(remoteServer: mockRemoteServer)
        
        mockRemoteServer.onFetch = {
            throw NSError(domain: "Server error", code: 0, userInfo: nil)
        }
        
        let expErrorMessage = expectation(description: "errorMessage")
        var cancellables: [AnyCancellable] = []
        viewModel.$errorMessage
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink{
                if $0 == SitesViewError.failedToLoadSites.localizedDescription {
                    expErrorMessage.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.send(.onAppear)

        wait(for: [expErrorMessage], timeout: 1)

    }
    
    /// onTapSite -> Navigator
    func testOnAppear_onTapSite_navigates() throws {
        var mockNavigator = MockNavigator()
        
        let expNavigate = expectation(description: "navigateToSiteDetail")
        var site = Site.stubSamples[0]
        site.id = "UT3ID"
        
        mockNavigator.onNavigateToSiteDetail = {
            if $0.id == site.id { expNavigate.fulfill() }
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
