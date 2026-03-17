//
//  AppDIContainer.swift
//  App
//
//  Created by 서정원 on 3/14/26.
//

import Data
import Domain
import Presentation

final class AppDIContainer {
    // MARK: - Repository
    private lazy var geocodingRepository: GeocodingRepository = DefaultGeocodingRepository()
    private lazy var photoRepository: PhotoRepository = DefaultPhotoRepository()

    // MARK: - UseCase
    private lazy var reverseGeocodeUseCase: ReverseGeocodeUseCase = DefaultReverseGeocodeUseCase(repository: geocodingRepository)
    private lazy var locationSuggestionUseCase: LocationSuggestionUseCase = DefaultLocationSuggestionUseCase(reverseGeocodeUseCase: reverseGeocodeUseCase)

    // MARK: - Adapter
    private lazy var photoPickerAdapter: PhotoPickerAdaptable = PhotoPickerAdapter(photoRepository: photoRepository)
    
    // MARK: - Factory
    func makeCreateRecordViewController() -> CreateRecordViewController {
        let viewModel = CreateRecordViewModel(locationSuggestionUseCase: locationSuggestionUseCase)
        let coordinator = CreateRecordCoordinator(photoAdapter: photoPickerAdapter)
        return CreateRecordViewController(
            viewModel: viewModel,
            coordinator: coordinator
        )
    }
}
