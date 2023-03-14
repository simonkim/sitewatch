//
//  EndPoints.swift
//  DemoAreaWatch
//
//  Created by Simon Kim on 2023/04/23.
//

import Foundation

extension URLEndpoint {
    static let areasURL = URL(string: "https://api.demo-area-watch.com/areas/client?cid=1234")!
    static let areasPageQueryItemName = "page"
    
    static func areas(page: Int?) -> Self {
        var queryItems: [URLQueryItem] = []
        if let page = page {
            queryItems.append(URLQueryItem(name: areasPageQueryItemName, value: "\(page)"))
        }

        return URLEndpoint(baseURL: areasURL, queryItems: queryItems)
    }
}
