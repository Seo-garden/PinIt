//
//  LocationRepository.swift
//  Domain
//
//  Created by 서정원 on 3/20/26.
//

import Foundation

public protocol LocationRepository {
    func requestAuthorization()
    func fetchCurrentLocation(completion: @escaping (Result<Coordinate, LocationError>) -> Void)
}
