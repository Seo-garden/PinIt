//
//  CreateRecordCoordinator.swift
//  Presentation
//
//  Created by 서정원 on 3/12/26.
//

import AVFoundation
import Domain
import Photos
import UIKit

public final class CreateRecordCoordinator {
    private let photoAdapter: PhotoPickerAdaptable
    private let searchLocationUseCase: SearchLocationUseCase

    public init(photoAdapter: PhotoPickerAdaptable, searchLocationUseCase: SearchLocationUseCase) {
        self.photoAdapter = photoAdapter
        self.searchLocationUseCase = searchLocationUseCase
    }

    func presentCamera(
        from controller: UIViewController,
        completion: @escaping (Result<[PhotoData], PhotoError>) -> Void,
        onPermissionDenied: @escaping (PermissionSource) -> Void
    ) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            photoAdapter.presentCamera(from: controller, completion: completion)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    if granted {
                        self.photoAdapter.presentCamera(from: controller, completion: completion)
                    } else {
                        onPermissionDenied(.camera)
                    }
                }
            }
        case .denied, .restricted:
            onPermissionDenied(.camera)
        @unknown default:
            onPermissionDenied(.camera)
        }
    }

    func presentGallery(
        from controller: UIViewController,
        maxAdditionalCount: Int,
        completion: @escaping (Result<[PhotoData], PhotoError>) -> Void,
        onPermissionDenied: @escaping (PermissionSource) -> Void
    ) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            photoAdapter.presentGallery(from: controller, maxAdditionalCount: maxAdditionalCount, completion: completion)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                Task { @MainActor in
                    if newStatus == .authorized || newStatus == .limited {
                        self.photoAdapter.presentGallery(from: controller, maxAdditionalCount: maxAdditionalCount, completion: completion)
                    } else {
                        onPermissionDenied(.photoLibrary)
                    }
                }
            }
        default:
            onPermissionDenied(.photoLibrary)
        }
    }
    
    func pushLocationSearch(from controller: UIViewController, onLocationSelected: @escaping (LocationSearchItem) -> Void) {
        let viewModel = LocationSearchViewModel(searchLocationUseCase: searchLocationUseCase)
        let searchVC = LocationSearchViewController(viewModel: viewModel)
        searchVC.onLocationSelected = onLocationSelected
        controller.navigationController?.pushViewController(searchVC, animated: true)
    }

    func presentPhotoDetail(from controller: UIViewController, images: [UIImage], initialPage: Int) {
        let photoDetailVC = PhotoDetailViewController(images: images, initialPage: initialPage)
        controller.present(photoDetailVC, animated: true)
    }

    func showAlert(from controller: UIViewController, title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        controller.present(alert, animated: true)
    }
}
