//
//  SitesNavigatorTests.swift
//  SiteWatchTests
//
//  Created by Simon Kim on 11/17/23.
//

import XCTest
import Combine
@testable import SiteWatch

final class SitesNavigatorTests: XCTestCase {
    var justDummyPublisher: AnyPublisher<SiteEvent, Never> {
        Just<SiteEvent>(
            MeasurementEvent(
                deviceId: "dummy",
                measurement: .init(unit: .humidity, measurement: 10)
            )).eraseToAnyPublisher()
    }

    func testNavigateToSiteDetail_pushes_SiteDetailViewController() throws {
        
        let navigationController = MockNavigationController()
        let navigator = SitesNavigatorImpl(
            dependency: .init(
                logger: MockLogger(),
                remoteEvents: justDummyPublisher,
                navigationController: navigationController
            )
        )

        let exp = navigationController.expectOnPush("pushed") {
            type(of:$0) == SiteDetailViewController.self && $1
        }
        navigator.navigate(to: .siteDetail(Site.stubSamples[0]))
        wait(for: [exp], timeout: 1)
    }

    func testNavigateToSiteDetail_withoutNavigationController_errorLogged() throws {
        let logger = MockLogger()
        let navigator = SitesNavigatorImpl(
            dependency: .init(
                logger: logger,
                remoteEvents: justDummyPublisher
            )
        )
        
        let exp = logger.expect("logged") { $0 == .error && $1.count > 0 }
        navigator.navigate(to: .siteDetail(Site.stubSamples[0]))
        wait(for: [exp], timeout: 1)
    }
}

extension MockNavigationController {
    func expectOnPush(_ description: String, check: @escaping (UIViewController, Bool) -> Bool) -> XCTestExpectation {
        let exp = XCTestExpectation(description: description)
        onPush = {
            if check($0, $1) {
                exp.fulfill()
            }
        }
        return exp
    }
}

extension MockLogger {
    func expect(_ description: String, check: @escaping (LogCategory, String) -> Bool) -> XCTestExpectation {
        let exp = XCTestExpectation(description: description)
        onLog = {
            if check($0, $1) {
                exp.fulfill()
            }
        }
        return exp
    }
}
