//
//  Coordinate.swift
//  Domain
//
//  Created by 서정원 on 3/13/26.
//

import Foundation

public struct Coordinate: Equatable, Hashable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public extension Coordinate {
    func isApproximatelyEqual(to other: Coordinate, epsilon: Double = 0.00001) -> Bool {
        abs(latitude - other.latitude) < epsilon && abs(longitude - other.longitude) < epsilon
    }
}
