//
//  DefaultReverseGeocodeUseCase.swift
//  Domain
//
//  Created by 서정원 on 3/13/26.
//

import Foundation

public protocol ReverseGeocodeUseCase {
    func execute(coordinate: Coordinate, completion: @escaping (String?) -> Void)
}

public struct DefaultReverseGeocodeUseCase: ReverseGeocodeUseCase {
    private let repository: GeocodingRepository

    public init(repository: GeocodingRepository) {
        self.repository = repository
    }

    public func execute(coordinate: Coordinate, completion: @escaping (String?) -> Void) {
        repository.reverseGeocode(coordinate: coordinate, completion: completion)
    }
}
