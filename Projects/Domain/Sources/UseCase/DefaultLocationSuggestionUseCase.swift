//
//  DefaultLocationSuggestionUseCase.swift
//  Domain
//
//  Created by 서정원 on 3/14/26.
//

import Foundation

public final class DefaultLocationSuggestionUseCase: LocationSuggestionUseCase {
    private let reverseGeocodeUseCase: ReverseGeocodeUseCase

    public init(reverseGeocodeUseCase: ReverseGeocodeUseCase) {
        self.reverseGeocodeUseCase = reverseGeocodeUseCase
    }

    public func resolve(from photos: [PhotoData], completion: @escaping ([SuggestedLocation]) -> Void) {
        let coords = uniqueCoordinates(photos.compactMap { $0.coordinate })
        guard !coords.isEmpty else {
            completion([])
            return
        }

        let group = DispatchGroup()
        var results: [(Int, SuggestedLocation)] = []
        let queue = DispatchQueue(label: "com.location.suggestion.queue")

        for (index, coord) in coords.enumerated() {
            group.enter()
            reverseGeocodeUseCase.execute(coordinate: coord) { address in
                if let address = address {
                    queue.async {
                        results.append((index, SuggestedLocation(coordinate: coord, title: address)))
                        group.leave()
                    }
                } else {
                    queue.async {
                        group.leave()
                    }
                }
            }
        }

        group.notify(queue: .main) {
            let sortedResults = results.sorted { $0.0 < $1.0 }.map { $0.1 }
            completion(sortedResults)
        }
    }

    public func resolve(from photos: [PhotoData]) async -> [SuggestedLocation] {
        await withCheckedContinuation { continuation in
            resolve(from: photos) { result in
                continuation.resume(returning: result)
            }
        }
    }

    private func uniqueCoordinates(_ coords: [Coordinate]) -> [Coordinate] {
        var seen: Set<String> = []
        var ordered: [Coordinate] = []
        for coord in coords {
            let key = coordinateKey(coord)
            if !seen.contains(key) {
                seen.insert(key)
                ordered.append(coord)
            }
        }
        return ordered
    }

    private func coordinateKey(_ coord: Coordinate) -> String {
        let lat = (coord.latitude * 1e5).rounded() / 1e5
        let lon = (coord.longitude * 1e5).rounded() / 1e5
        return "\(lat)_\(lon)"
    }
}
