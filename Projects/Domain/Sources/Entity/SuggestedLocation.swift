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
        lhs.title == rhs.title && lhs.coordinate == rhs.coordinate
    }
    
    public func isApproximatelySame(as other: SuggestedLocation, epsilon: Double = 0.00001) -> Bool {
        title == other.title && coordinate.isApproximatelyEqual(to: other.coordinate, epsilon: epsilon)
    }
}
