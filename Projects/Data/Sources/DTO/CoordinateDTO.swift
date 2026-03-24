//
//  CoordinateDTO.swift
//  Data
//
//  Created by 서정원 on 3/14/26.
//

import Domain

public struct CoordinateDTO {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public func toDomain() -> Coordinate? {
        return Coordinate(latitude: latitude, longitude: longitude)
    }
}
