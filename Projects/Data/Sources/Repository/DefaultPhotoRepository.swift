//
//  DefaultPhotoRepository.swift
//  Data
//
//  Created by 서정원 on 3/13/26.
//

import CoreLocation
import Domain
import Foundation
import Photos

public struct DefaultPhotoRepository: PhotoRepository {
    public init() {}

    public func loadFromCamera(imageData: Data, metadata: [AnyHashable: Any], completion: @escaping (Result<[PhotoData], PhotoError>) -> Void) {
        let coordinateDTO = EXIFCoordinateExtractor.extractCoordinate(fromMetadata: metadata)
            ?? EXIFCoordinateExtractor.extractCoordinate(fromData: imageData)
        let photoDTO = PhotoDataDTO(imageData: imageData, coordinate: coordinateDTO)
        completion(.success([photoDTO.toDomain()]))
    }

    public func loadFromGallery(assetIdentifiers: [String], completion: @escaping (Result<[PhotoData], PhotoError>) -> Void) {
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
        guard fetchResult.count > 0 else {
            completion(.success([]))
            return
        }

        var assetsByIdentifier: [String: PHAsset] = [:]
        fetchResult.enumerateObjects { asset, _, _ in
            assetsByIdentifier[asset.localIdentifier] = asset
        }
        let orderedAssets = assetIdentifiers.compactMap { assetsByIdentifier[$0] }

        let group = DispatchGroup()
        var collected = [PhotoData?](repeating: nil, count: orderedAssets.count)
        var hasFailure = false
        let syncQueue = DispatchQueue(label: "photo.repository.queue")

        for (index, asset) in orderedAssets.enumerated() {
            group.enter()
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.version = .current
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, info in
                defer { group.leave() }
                if info?[PHImageErrorKey] is Error {
                    syncQueue.async { hasFailure = true }
                    return
                }
                guard let data else {
                    syncQueue.async { hasFailure = true }
                    return
                }
                let coordinateDTO = EXIFCoordinateExtractor.extractCoordinate(fromData: data)
                    ?? asset.location.map { CoordinateDTO(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
                let photoDTO = PhotoDataDTO(imageData: data, coordinate: coordinateDTO)
                syncQueue.async { collected[index] = photoDTO.toDomain() }
            }
        }

        group.notify(queue: .main) {
            let ordered = syncQueue.sync { (hasFailure, collected.compactMap { $0 }) }
            if ordered.0 {
                completion(.failure(.loadFailed))
            } else {
                completion(.success(ordered.1))
            }
        }
    }

    public func loadFromImageData(_ items: [Data], completion: @escaping (Result<[PhotoData], PhotoError>) -> Void) {
        let photos = items.map { data -> PhotoData in
            let coordinateDTO = EXIFCoordinateExtractor.extractCoordinate(fromData: data)
            return PhotoDataDTO(imageData: data, coordinate: coordinateDTO).toDomain()
        }
        DispatchQueue.main.async {
            completion(.success(photos))
        }
    }
}
