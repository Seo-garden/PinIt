//
//  Coordinate+CoreLocation.swift
//  Presentation
//
//  Created by 서정원 on 3/13/26.
//

import CoreLocation
import Domain

extension Coordinate {
    var clLocationCoordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(_ coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
