//
//  DefaultGeocodingRepository.swift
//  Data
//
//  Created by 서정원 on 3/13/26.
//

import CoreLocation
import Domain

public struct DefaultGeocodingRepository: GeocodingRepository {
    private let geocoderProvider: () -> CLGeocoder

    public init(geocoderProvider: @escaping () -> CLGeocoder = { CLGeocoder() }) {
        self.geocoderProvider = geocoderProvider
    }

    public func reverseGeocode(coordinate: Coordinate, completion: @escaping (String?) -> Void) {
        let geocoder = geocoderProvider()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            let address = placemarks?.first.map { placemark in
                [placemark.country, placemark.administrativeArea,
                 placemark.locality, placemark.subLocality, placemark.name]
                    .compactMap { $0 }
                    .joined(separator: " ")
            }
            completion(address)
        }
    }
}
