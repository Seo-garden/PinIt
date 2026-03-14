//
//  GeocodingRepository.swift
//  Domain
//
//  Created by 서정원 on 3/13/26.
//

import Foundation

public protocol GeocodingRepository {
    func reverseGeocode(coordinate: Coordinate, completion: @escaping (String?) -> Void)
}
