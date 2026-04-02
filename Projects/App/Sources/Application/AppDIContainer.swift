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

final class AppDIContainer {
    // MARK: - Repository
    private lazy var geocodingRepository: GeocodingRepository = DefaultGeocodingRepository()
    private lazy var photoRepository: PhotoRepository = DefaultPhotoRepository()
    private lazy var locationRepository: LocationRepository = DefaultLocationRepository()
    private lazy var recordRepository: RecordRepository = InMemoryRecordRepository()

    // MARK: - UseCase
    private lazy var reverseGeocodeUseCase: ReverseGeocodeUseCase = DefaultReverseGeocodeUseCase(repository: geocodingRepository)
    private lazy var locationSuggestionUseCase: LocationSuggestionUseCase = DefaultLocationSuggestionUseCase(reverseGeocodeUseCase: reverseGeocodeUseCase)
    private lazy var fetchUserLocationUseCase: FetchUserLocationUseCase = DefaultFetchUserLocationUseCase(repository: locationRepository)
    private lazy var locationSearchRepository: LocationSearchRepository = DefaultLocationSearchRepository()
    private lazy var searchLocationUseCase: SearchLocationUseCase = DefaultSearchLocationUseCase(repository: locationSearchRepository)
    private lazy var saveRecordUseCase: SaveRecordUseCase = DefaultSaveRecordUseCase(repository: recordRepository)
    private lazy var fetchAllRecordsUseCase: FetchAllRecordsUseCase = DefaultFetchAllRecordsUseCase(repository: recordRepository)
    private lazy var deleteRecordUseCase: DeleteRecordUseCase = DefaultDeleteRecordUseCase(repository: recordRepository)
    private lazy var updateRecordCaptionUseCase: UpdateRecordCaptionUseCase = DefaultUpdateRecordCaptionUseCase(repository: recordRepository)

    // MARK: - Adapter
    private lazy var photoPickerAdapter: PhotoPickerAdaptable = PhotoPickerAdapter(photoRepository: photoRepository, fetchUserLocationUseCase: fetchUserLocationUseCase)
    
    // MARK: - Factory
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

    func makeDetailRecordViewController(record: Record) -> DetailRecordViewController {
        let viewModel = DetailRecordViewModel(
            record: record,
            deleteRecordUseCase: deleteRecordUseCase,
            updateRecordCaptionUseCase: updateRecordCaptionUseCase
        )
        let coordinator = DetailRecordCoordinator()
        return DetailRecordViewController(viewModel: viewModel, coordinator: coordinator)
    }
}
