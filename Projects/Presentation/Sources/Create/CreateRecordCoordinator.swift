//
//  CreateRecordCoordinator.swift
//  Presentation
//
//  Created by 서정원 on 3/12/26.
//

import AVFoundation
import CoreLocation
import Domain
import Photos
import UIKit

public final class CreateRecordCoordinator {
    weak var hostViewController: UIViewController?
    private let photoAdapter: PhotoPickerAdaptable

    public init(photoAdapter: PhotoPickerAdaptable) {
        self.photoAdapter = photoAdapter
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
    
    func pushLocationSearch(from controller: UIViewController) {
        let viewModel = LocationSearchViewModel()
        let searchVC = LocationSearchViewController(viewModel: viewModel)
        controller.navigationController?.pushViewController(searchVC, animated: true)
    }

    func showAlert(from controller: UIViewController, title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        controller.present(alert, animated: true)
    }
}
