//
//  DefaultLocationSuggestionUseCase.swift
//  Domain
//
//  Created by 서정원 on 3/14/26.
//

import Foundation

public protocol LocationSuggestionUseCase {
    func resolve(from photos: [PhotoData], completion: @escaping ([SuggestedLocation]) -> Void)
}

public struct DefaultLocationSuggestionUseCase: LocationSuggestionUseCase {
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
                queue.async {
                    if let address = address {
                        results.append((index, SuggestedLocation(coordinate: coord, title: address)))
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            let sortedResults = results.sorted { $0.0 < $1.0 }.map { $0.1 }
            completion(sortedResults)
        }
    }
    
    private func uniqueCoordinates(_ coords: [Coordinate]) -> [Coordinate] {
        var seen: Set<String> = []
        return coords.filter { seen.insert($0.uniqueKey()).inserted }
    }
}
