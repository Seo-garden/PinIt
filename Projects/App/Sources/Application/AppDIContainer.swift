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

    // MARK: - UseCase
    private lazy var reverseGeocodeUseCase: ReverseGeocodeUseCase = DefaultReverseGeocodeUseCase(repository: geocodingRepository)
    private lazy var locationSuggestionUseCase: LocationSuggestionUseCase = DefaultLocationSuggestionUseCase(reverseGeocodeUseCase: reverseGeocodeUseCase)
    private lazy var fetchUserLocationUseCase: FetchUserLocationUseCase = DefaultFetchUserLocationUseCase(repository: locationRepository)

    // MARK: - Adapter
    private lazy var photoPickerAdapter: PhotoPickerAdaptable = PhotoPickerAdapter(photoRepository: photoRepository, fetchUserLocationUseCase: fetchUserLocationUseCase)
    
    // MARK: - Factory
    func makeOnboardingViewController(onFinished: @escaping () -> Void) -> OnboardingViewController {
        OnboardingViewController(
            viewModel: OnboardingViewModel(),
            onFinished: onFinished
        )
    }

    func makeLoginViewController(onLoginSucceeded: @escaping () -> Void) -> UINavigationController {
        let viewController = LoginViewController(
            viewModel: LoginViewModel(),
            onLoginSucceeded: onLoginSucceeded
        )
        return UINavigationController(rootViewController: viewController)
    }

    func makeMainTabBarController() -> TabBarViewController {
        return TabBarViewController(
            mapViewController: makeMapViewController(),
            feedViewController: makeFeedViewController(),
            createRecordViewController: makeCreateRecordViewController()
        )
    }

    private func makeMapViewController() -> MapViewController {
        return MapViewController(viewModel: MapViewModel(fetchUserLocationUseCase: fetchUserLocationUseCase))
    }

    private func makeFeedViewController() -> FeedViewController {
        return FeedViewController(viewModel: FeedViewModel())
    }

    private func makeCreateRecordViewController() -> CreateRecordViewController {
        let viewModel = CreateRecordViewModel(locationSuggestionUseCase: locationSuggestionUseCase)
        let coordinator = CreateRecordCoordinator(photoAdapter: photoPickerAdapter)
        return CreateRecordViewController(
            viewModel: viewModel,
            coordinator: coordinator
        )
    }
}
