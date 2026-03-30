//
//  DefaultLocationSearchRepository.swift
//  Data
//
//  Created by 서정원 on 3/26/26.
//

import Domain
import Foundation
import MapKit

public struct DefaultLocationSearchRepository: LocationSearchRepository {
    public init() {}

    @discardableResult
    public func search(query: String, completion: @escaping (Result<[LocationSearchResult], LocationError>) -> Void) -> Cancellable {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if error != nil {
                completion(.failure(.searchFailed))
                return
            }

            guard let response else {
                completion(.success([]))
                return
            }

            let results = response.mapItems.compactMap { item -> LocationSearchResult? in
                let coordinate = Coordinate(
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude
                )
                guard let coordinate else { return nil }

                let name = item.name ?? ""
                let address = [
                    item.placemark.locality,
                    item.placemark.subLocality,
                    item.placemark.thoroughfare,
                    item.placemark.subThoroughfare
                ]
                .compactMap { $0 }
                .joined(separator: " ")

                return LocationSearchResult(name: name, address: address, coordinate: coordinate)
            }

            completion(.success(results))
        }

        return MKLocalSearchCancellable(search: search)
    }
}

private struct MKLocalSearchCancellable: Cancellable {
    private let search: MKLocalSearch

    init(search: MKLocalSearch) {
        self.search = search
    }

    func cancel() {
        search.cancel()
    }
}
