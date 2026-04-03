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
    
    public func isApproximatelySame(as other: SuggestedLocation, epsilon: Double = 0.00001) -> Bool {
        title == other.title && coordinate.isApproximatelyEqual(to: other.coordinate, epsilon: epsilon)
    }
}
