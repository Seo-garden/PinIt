//
//  Cancellable.swift
//  Domain
//
//  Created by 서정원 on 3/30/26.
//

import Foundation

public protocol Cancellable {
    func cancel()
}

public struct EmptyCancellable: Cancellable {
    public init() {}
    public func cancel() {}
}
