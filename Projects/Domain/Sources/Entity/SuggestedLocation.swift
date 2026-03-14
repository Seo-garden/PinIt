//
//  SuggestedLocation.swift
//  Domain
//

import Foundation

public struct SuggestedLocation: Equatable {
    public let coordinate: Coordinate
    public let title: String

    public init(coordinate: Coordinate, title: String) {
        self.coordinate = coordinate
        self.title = title
    }

    public static func == (lhs: SuggestedLocation, rhs: SuggestedLocation) -> Bool {
        lhs.title == rhs.title && lhs.coordinate.isApproximatelyEqual(to: rhs.coordinate)
    }
}
