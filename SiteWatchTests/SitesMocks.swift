//
//  SitesMocks.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/16/23.
//

import UIKit
import Combine
@testable import SiteWatch

class MockNavigationController: UIKitNavigatable {
    var onPush: (UIViewController, Bool) -> Void = { _, _ in }
    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        onPush(viewController, animated)
    }
}

extension SitesViewModelImpl {
    static func mocked(
        remoteServer: RemoteServer = MockRemoteServer(),
        imageStore: ImageStore = MockImageStore(),
        logger: AppLogger = MockLogger(),
        navigator: SitesNavigator = SitesNavigatorStub()) -> SitesViewModelImpl
    {
        return SitesViewModelImpl(
            remoteServer: remoteServer,
            imageStore: imageStore,
            logger: logger,
            navigator: navigator
        )
    }
}

class MockRemoteServer: RemoteServer {
    var onFetch: () throws -> [SiteWatch.Site] = { return [] }
    
    func fetchSites() async throws -> [SiteWatch.Site] {
        return try onFetch()
    }
    
    func eventPublisher() -> AnyPublisher<SiteWatch.SiteEvent, Never> {
        let event = MeasurementEvent.sensor("pool-sensor", .temperature, 27)
        return Just(event)
            .eraseToAnyPublisher()
    }
}

class MockImageStore: ImageStore {
    func getImage(from url: URL, targetSize: CGSize) async throws -> UIImage {
        return UIImage(systemName: "sensor")!
    }

}

class MockLogger: AppLogger {
    var onLog: (LogCategory, String) -> Void = { _, _ in  }

    func log(_ category: LogCategory, _ text: String) {
        onLog(category, text)
    }
}

struct MockNavigator: SitesNavigator {
    var onNavigateTo: (SitesNavigationTarget) -> Void = { _ in  }

    func navigate(to target: SitesNavigationTarget) {
        onNavigateTo(target)
    }
}
