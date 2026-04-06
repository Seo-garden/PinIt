//
//  PhotoPickerAdapter.swift
//  Presentation
//
//  Created by 서정원 on 3/13/26.
//

import Domain
import PhotosUI
import UIKit

public final class PhotoPickerAdapter: NSObject, PhotoPickerAdaptable {
    private let loadPhotoFromCameraUseCase: LoadPhotoFromCameraUseCase
    private let loadPhotoFromGalleryUseCase: LoadPhotoFromGalleryUseCase
    private let fetchUserLocationUseCase: FetchUserLocationUseCase
    private var completion: ((Result<[PhotoData], PhotoError>) -> Void)?
    private var fallbackCoordinate: Coordinate?

    public init(loadPhotoFromCameraUseCase: LoadPhotoFromCameraUseCase, loadPhotoFromGalleryUseCase: LoadPhotoFromGalleryUseCase, fetchUserLocationUseCase: FetchUserLocationUseCase) {
        self.loadPhotoFromCameraUseCase = loadPhotoFromCameraUseCase
        self.loadPhotoFromGalleryUseCase = loadPhotoFromGalleryUseCase
        self.fetchUserLocationUseCase = fetchUserLocationUseCase
        super.init()
    }

    public func presentCamera(from controller: UIViewController, completion: @escaping (Result<[PhotoData], PhotoError>) -> Void) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            completion(.failure(.unavailable))
            return
        }
        self.completion = completion
        self.fallbackCoordinate = nil
        fetchUserLocationUseCase.execute { [weak self] result in
            if case .success(let coordinate) = result {
                self?.fallbackCoordinate = coordinate
            }
        }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = false
        picker.modalPresentationStyle = .fullScreen
        controller.present(picker, animated: true)
    }

    public func presentGallery(from controller: UIViewController, maxAdditionalCount: Int, completion: @escaping (Result<[PhotoData], PhotoError>) -> Void) {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = maxAdditionalCount
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        self.completion = completion
        picker.delegate = self
        controller.present(picker, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension PhotoPickerAdapter: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [weak self] in
            self?.fallbackCoordinate = nil
            self?.completion = nil
        }
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            guard let image = info[.originalImage] as? UIImage,
                  let imageData = image.jpegData(compressionQuality: 1.0) else {
                self.completion?(.failure(.loadFailed))
                self.completion = nil
                return
            }
            
            let metadata = info[.mediaMetadata] as? [AnyHashable: Any] ?? [:]
            let fallback = self.fallbackCoordinate
            self.loadPhotoFromCameraUseCase.execute(imageData: imageData, metadata: metadata) { [weak self] result in
                switch result {
                case .success(let photos):
                    let adjusted = photos.map { photo in
                        if photo.coordinate == nil, let fallback {
                            return PhotoData(imageData: photo.imageData, coordinate: fallback)
                        }
                        return photo
                    }
                    self?.completion?(.success(adjusted))
                case .failure:
                    self?.completion?(result)
                }
                self?.fallbackCoordinate = nil
                self?.completion = nil
            }
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension PhotoPickerAdapter: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else {
            completion = nil
            return
        }

        let identifiers = results.compactMap { $0.assetIdentifier }

        guard !identifiers.isEmpty else {
            loadViaItemProviders(results: results)
            return
        }

        loadPhotoFromGalleryUseCase.execute(assetIdentifiers: identifiers) { [weak self] result in
            self?.completion?(result)
            self?.completion = nil
        }
    }

    private func loadViaItemProviders(results: [PHPickerResult]) {
        let group = DispatchGroup()
        var collected: [PhotoData] = []
        let syncQueue = DispatchQueue(label: "photo.picker.fallback.queue")

        for result in results {
            guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else { continue }
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                defer { group.leave() }
                guard let image = object as? UIImage else { return }
                guard let data = image.jpegData(compressionQuality: 1.0) else { return }
                let photo = PhotoData(imageData: data, coordinate: nil)
                syncQueue.async { collected.append(photo) }
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            syncQueue.sync {}
            if collected.isEmpty {
                self.completion?(.failure(.loadFailed))
            } else {
                self.completion?(.success(collected))
            }
            self.completion = nil
        }
    }
}
