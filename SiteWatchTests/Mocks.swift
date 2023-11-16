//
//  Mocks.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/16/23.
//

import UIKit
import Combine
@testable import SiteWatch

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

struct MockLogger: AppLogger {
    func log(_ category: LogCategory, _ text: String) {
        
    }
}

struct MockNavigator: SitesNavigator {
    var onNavigateToSiteDetail: (Site) -> Void = { _ in  }

    func navigate(toSiteDetail site: Site) {
        onNavigateToSiteDetail(site)
    }
}
