//
//  ModelTypes.swift
//  AreaWatchDemo
//
//  Created by Simon Kim on 11/8/23.
//

import Foundation

enum LoadingState: Equatable {
    case loading
    case finished(Error?)

}

extension LoadingState {
    init(isLoading: Bool, error: Error?) {
        switch isLoading {
        case true:
            self = .loading
        case false:
            self = .finished(error)
        }
    }
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var error: Error? {
        guard case .finished(let e) = self else {
            return nil
        }
        return e
    }
    
    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):  return true
            
        case (.finished(let lhsError), .finished(let rhsError)):
            return equal(lhsError, rhsError)
            
        default:                    return false
        }
    }
    
    static func equal<T: Error>(_ lhs: T?, _ rhs: T?) -> Bool {
        if lhs == nil, rhs == nil {
            return true
        }
        guard let lhs = lhs, let rhs = rhs else {
            return false
        }
        guard String(describing: lhs) == String(describing: rhs) else {
            return false
        }
        return (lhs as NSError).isEqual(rhs as NSError)
    }
}
