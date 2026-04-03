//
//  LocationSearchResult.swift
//  Domain
//
//  Created by 서정원 on 3/26/26.
//

import Foundation

public struct LocationSearchResult: Equatable {
    public let name: String
    public let address: String
    public let coordinate: Coordinate

    public init(name: String, address: String, coordinate: Coordinate) {
        self.name = name
        self.address = address
        self.coordinate = coordinate
    }
}
