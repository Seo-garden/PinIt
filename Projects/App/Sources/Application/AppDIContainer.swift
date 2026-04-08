//
//  AppDIContainer.swift
//  App
//
//  Created by 서정원 on 3/14/26.
//

import Data
import Domain
import Presentation
import UIKit

@MainActor
final class AppDIContainer {
    // MARK: - Repository
    private lazy var geocodingRepository: GeocodingRepository = DefaultGeocodingRepository()
    private lazy var photoRepository: PhotoRepository = DefaultPhotoRepository()
    private lazy var locationRepository: LocationRepository = DefaultLocationRepository()
    private lazy var recordRepository: RecordRepository = InMemoryRecordRepository()
    private lazy var authRepository: AuthRepository = DefaultAuthRepository()
    private lazy var locationSearchRepository: LocationSearchRepository = DefaultLocationSearchRepository()
    private lazy var authSessionRepository: AuthSessionRepository = DefaultAuthSessionRepository()
    private lazy var onboardingContentRepository: OnboardingContentRepository = DefaultOnboardingContentRepository()
    private lazy var onboardingStatusRepository: OnboardingStatusRepository = DefaultOnboardingStatusRepository()

    // MARK: - UseCase
    private lazy var reverseGeocodeUseCase: ReverseGeocodeUseCase = DefaultReverseGeocodeUseCase(repository: geocodingRepository)
    private lazy var locationSuggestionUseCase: LocationSuggestionUseCase = DefaultLocationSuggestionUseCase(reverseGeocodeUseCase: reverseGeocodeUseCase)
    private lazy var fetchUserLocationUseCase: FetchUserLocationUseCase = DefaultFetchUserLocationUseCase(repository: locationRepository)
    private lazy var searchLocationUseCase: SearchLocationUseCase = DefaultSearchLocationUseCase(repository: locationSearchRepository)
    private lazy var saveRecordUseCase: SaveRecordUseCase = DefaultSaveRecordUseCase(repository: recordRepository)
    private lazy var fetchAllRecordsUseCase: FetchAllRecordsUseCase = DefaultFetchAllRecordsUseCase(repository: recordRepository)
    private lazy var deleteRecordUseCase: DeleteRecordUseCase = DefaultDeleteRecordUseCase(repository: recordRepository)
    private lazy var updateRecordCaptionUseCase: UpdateRecordCaptionUseCase = DefaultUpdateRecordCaptionUseCase(repository: recordRepository)
    private lazy var signInUseCase: SignInUseCase = DefaultSignInUseCase(authRepository: authRepository)
    private lazy var loadPhotoFromCameraUseCase: LoadPhotoFromCameraUseCase = DefaultLoadPhotoFromCameraUseCase(repository: photoRepository)
    private lazy var loadPhotoFromGalleryUseCase: LoadPhotoFromGalleryUseCase = DefaultLoadPhotoFromGalleryUseCase(repository: photoRepository)
    private lazy var signOutUseCase: SignOutUseCase = DefaultSignOutUseCase(authRepository: authRepository)
    private lazy var deleteAccountUseCase: DeleteAccountUseCase = DefaultDeleteAccountUseCase(authRepository: authRepository)
    private lazy var resetPasswordUseCase: ResetPasswordUseCase = DefaultResetPasswordUseCase(authRepository: authRepository)
    private lazy var fetchCurrentUserUseCase: FetchCurrentUserUseCase = DefaultFetchCurrentUserUseCase(authSessionRepository: authSessionRepository)

    // MARK: - Adapter
    private lazy var photoPickerAdapter: PhotoPickerAdaptable = PhotoPickerAdapter(loadPhotoFromCameraUseCase: loadPhotoFromCameraUseCase, loadPhotoFromGalleryUseCase: loadPhotoFromGalleryUseCase, fetchUserLocationUseCase: fetchUserLocationUseCase)

    // MARK: - Factory
    func makeOnboardingViewController(onFinished: @escaping () -> Void) -> OnboardingViewController {
        OnboardingViewController(
            viewModel: OnboardingViewModel(
                onboardingContentRepo: onboardingContentRepository,
                onboardingStatusRepo: onboardingStatusRepository
            ),
            onFinished: onFinished
        )
    }

    func makeLoginViewController(onLoginSucceeded: @escaping () -> Void) -> UINavigationController {
        let viewController = LoginViewController(
            viewModel: LoginViewModel(signInUseCase: signInUseCase),
            onLoginSucceeded: onLoginSucceeded
        )
        return UINavigationController(rootViewController: viewController)
    }

    func makeMainTabBarController(onLogout: @escaping () -> Void) -> TabBarViewController {
        return TabBarViewController(
            mapViewController: makeMapViewController(),
            feedViewController: makeFeedViewController(),
            makeCreateRecordViewController: makeCreateRecordViewController,
            settingViewController: makeSettingViewController(onLogout: onLogout)
        )
    }

    private func makeMapViewController() -> MapViewController {
        return MapViewController(viewModel: MapViewModel(fetchUserLocationUseCase: fetchUserLocationUseCase))
    }

    private func makeFeedViewController() -> FeedViewController {
        let viewModel = FeedViewModel(fetchAllRecordsUseCase: fetchAllRecordsUseCase)
        let coordinator = FeedCoordinator { [unowned self] record in
            self.makeDetailRecordViewController(record: record)
        }
        return FeedViewController(viewModel: viewModel, coordinator: coordinator)
    }

    private func makeCreateRecordViewController() -> CreateRecordViewController {
        let viewModel = CreateRecordViewModel(
            locationSuggestionUseCase: locationSuggestionUseCase,
            saveRecordUseCase: saveRecordUseCase
        )
        let coordinator = CreateRecordCoordinator(photoAdapter: photoPickerAdapter, searchLocationUseCase: searchLocationUseCase)
        return CreateRecordViewController(
            viewModel: viewModel,
            coordinator: coordinator
        )
    }

    func makeSettingViewController(onLogout: @escaping () -> Void) -> SettingViewController {
        let viewModel = SettingViewModel(
            fetchCurrentUserUseCase: fetchCurrentUserUseCase,
            signOutUseCase: signOutUseCase,
            deleteAccountUseCase: deleteAccountUseCase
        )
        return SettingViewController(viewModel: viewModel, onLogout: onLogout)
    }

    private func makeDetailRecordViewController(record: Record) -> DetailRecordViewController {
        let viewModel = DetailRecordViewModel(
            record: record,
            deleteRecordUseCase: deleteRecordUseCase,
            updateRecordCaptionUseCase: updateRecordCaptionUseCase
        )
        let coordinator = DetailRecordCoordinator()
        return DetailRecordViewController(viewModel: viewModel, coordinator: coordinator)
    }
}
