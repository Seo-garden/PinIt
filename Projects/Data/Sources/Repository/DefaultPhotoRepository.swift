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
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
        guard assets.count > 0 else {
            completion(.success([]))
            return
        }

        let group = DispatchGroup()
        var collected: [PhotoData] = []
        var hasFailure = false
        let syncQueue = DispatchQueue(label: "photo.repository.queue")

        assets.enumerateObjects { asset, _, _ in
            group.enter()
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.version = .current
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, info in
                defer { group.leave() }
                if let error = info?[PHImageErrorKey] as? Error {
                    debugPrint("[PhotoRepository] asset load failed: \(error.localizedDescription)")
                    syncQueue.async { hasFailure = true }
                    return
                }
                guard let data = data else {
                    syncQueue.async { hasFailure = true }
                    return
                }
                let coordinateDTO = EXIFCoordinateExtractor.extractCoordinate(fromData: data)
                    ?? asset.location.map { CoordinateDTO(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
                let photoDTO = PhotoDataDTO(imageData: data, coordinate: coordinateDTO)
                syncQueue.async { collected.append(photoDTO.toDomain()) }
            }
        }

        group.notify(queue: .main) {
            syncQueue.sync {}
            if hasFailure {
                completion(.failure(.loadFailed))
            } else {
                completion(.success(collected))
            }
        }
    }

    public func loadFromImageData(_ items: [Data], completion: @escaping (Result<[PhotoData], PhotoError>) -> Void) {
        let photos = items.map { data -> PhotoData in
            let coordinateDTO = EXIFCoordinateExtractor.extractCoordinate(fromData: data)
            return PhotoDataDTO(imageData: data, coordinate: coordinateDTO).toDomain()
        }
        completion(.success(photos))
    }
}
