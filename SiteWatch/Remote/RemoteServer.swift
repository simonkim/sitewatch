//
//  RemoteServer.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/14/23.
//

import Foundation
import Combine

protocol RemoteServer {
    func fetchSites() async throws -> [Site]
    func eventPublisher() -> AnyPublisher<SiteEvent, Never>
}

protocol SiteEvent {
    
}
