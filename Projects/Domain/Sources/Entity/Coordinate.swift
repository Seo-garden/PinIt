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
    
    public init?(latitude: Double, longitude: Double) {
        guard (-90.0...90.0).contains(latitude),
              (-180.0...180.0).contains(longitude) else {
            return nil
        }
        
        self.latitude = latitude
        self.longitude = longitude
    }
}

public extension Coordinate {
    func isApproximatelyEqual(to other: Coordinate, epsilon: Double = 0.00001) -> Bool {
        abs(latitude - other.latitude) < epsilon && abs(longitude - other.longitude) < epsilon
    }

    func uniqueKey(precision: Int = 5) -> String {
        let factor = pow(10.0, Double(precision))
        let lat = (latitude * factor).rounded() / factor
        let lon = (longitude * factor).rounded() / factor
        return "\(lat)_\(lon)"
    }
}
