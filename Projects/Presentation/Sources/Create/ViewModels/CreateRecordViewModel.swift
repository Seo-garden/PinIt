//
//  CreateRecordViewModel.swift
//  Presentation
//
//  Created by 서정원 on 3/13/26.
//

import Domain
import Foundation
import RxCocoa
import RxRelay
import RxSwift

public final class CreateRecordViewModel: ViewModelType {
    public static let maxPhotos = 5
    private let locationSuggestionUseCase: LocationSuggestionUseCase
    private let saveRecordUseCase: SaveRecordUseCase
    private var disposeBag = DisposeBag()

    public init(
        locationSuggestionUseCase: LocationSuggestionUseCase,
        saveRecordUseCase: SaveRecordUseCase
    ) {
        self.locationSuggestionUseCase = locationSuggestionUseCase
        self.saveRecordUseCase = saveRecordUseCase
    }

    public struct PhotoState: Equatable {
        public var photos: [PhotoData] = []
        public var currentPage: Int = 0
    }

    public struct FormState: Equatable {
        public var caption: String = ""
    }

    public struct LocationState: Equatable {
        public var locationName: String?
        public var coordinate: Coordinate?
        public var suggestions: [SuggestedLocation] = []
        public var isManuallySet: Bool = false

        public mutating func reset() {
            suggestions = []
            locationName = nil
            coordinate = nil
            isManuallySet = false
        }

        public static func == (lhs: LocationState, rhs: LocationState) -> Bool {
            lhs.locationName == rhs.locationName
                && lhs.coordinate == rhs.coordinate
                && lhs.suggestions == rhs.suggestions
                && lhs.isManuallySet == rhs.isManuallySet
        }
    }

    public struct State: Equatable {
        public var photo: PhotoState = .init()
        public var form: FormState = .init()
        public var location: LocationState = .init()

        public var hasPhotos: Bool {
            !photo.photos.isEmpty
        }

        public var pageBadgeText: String {
            hasPhotos
                ? "\(photo.currentPage + 1) / \(photo.photos.count)"
                : "0 / 0"
        }

        public var captionCountText: String {
            "\(form.caption.count) / \(RecordCaptionValidator.maxLength)"
        }

        public var isRecordEnabled: Bool {
            let trimmed = form.caption.trimmingCharacters(in: .whitespacesAndNewlines)
            return hasPhotos && !trimmed.isEmpty
        }
    }

    // MARK: - Mutation

    private enum Mutation {
        case setPhotos([PhotoData])
        case deletePhoto(Int)
        case setCaption(String)
        case setPage(Int)
        case setLocation(Coordinate?, String?)
        case setSearchedLocation(Coordinate, String)
        case setSuggestions([SuggestedLocation])
        case applySuggestion(Int)
    }

    private static func reduce(_ state: State, _ mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setPhotos(let newPhotos):
            newState.photo.photos = newPhotos
        case .deletePhoto(let index):
            if index < newState.photo.photos.count {
                newState.photo.photos.remove(at: index)
            }
            if newState.photo.currentPage >= newState.photo.photos.count {
                newState.photo.currentPage = max(0, newState.photo.photos.count - 1)
            }
        case .setCaption(let caption):
            newState.form.caption = caption
        case .setPage(let page):
            newState.photo.currentPage = page
        case .setLocation(let coord, let name):
            newState.location.coordinate = coord
            newState.location.locationName = name
            if coord == nil && name == nil {
                newState.location.isManuallySet = false
            }
        case .setSearchedLocation(let coord, let name):
            newState.location.coordinate = coord
            newState.location.locationName = name
            newState.location.isManuallySet = true
        case .setSuggestions(let suggestions):
            newState.location.suggestions = suggestions
            if !newState.location.isManuallySet {
                if suggestions.isEmpty {
                    newState.location.coordinate = nil
                    newState.location.locationName = nil
                } else if newState.location.locationName == nil {
                    newState.location.coordinate = suggestions[0].coordinate
                    newState.location.locationName = suggestions[0].title
                }
            }
        case .applySuggestion(let index):
            if index < newState.location.suggestions.count {
                let suggestion = newState.location.suggestions[index]
                newState.location.coordinate = suggestion.coordinate
                newState.location.locationName = suggestion.title
            }
        }

        if newState.photo.photos.isEmpty && !newState.location.isManuallySet {
            newState.location.reset()
        }

        return newState
    }

    public struct Input {
        public let takePhotoTap: Signal<Void>
        public let galleryTap: Signal<Void>
        public let addPhotos: Signal<[PhotoData]>
        public let deleteCurrentPhoto: Signal<Void>
        public let captionChanged: Signal<String>
        public let currentPageChanged: Signal<Int>
        public let clearLocationTap: Signal<Void>
        public let selectSuggestedLocation: Signal<Int>
        public let searchedLocation: Signal<(name: String, coordinate: Coordinate)>
        public let recordTap: Signal<Void>
    }

    public struct Output {
        public let state: Driver<State>
        public let requestCamera: Signal<Void>
        public let requestGallery: Signal<Int>
        public let showAlert: Signal<AlertMessage>
        public let finish: Signal<Record>
        public let photoDeleted: Signal<Int>
    }

    public func transform(input: Input) -> Output {
        let state = BehaviorRelay<State>(value: State())

        let requestCamera = input.takePhotoTap.asObservable()
            .withLatestFrom(state)
            .filter { $0.photo.photos.count < Self.maxPhotos }
            .map { _ in () }
            .asSignal(onErrorSignalWith: .empty())

        let requestGallery = input.galleryTap.asObservable()
            .withLatestFrom(state)
            .map { Self.maxPhotos - $0.photo.photos.count }
            .filter { $0 > 0 }
            .asSignal(onErrorSignalWith: .empty())

        let overLimitAlert = Observable.merge(input.takePhotoTap.asObservable(), input.galleryTap.asObservable())
            .withLatestFrom(state)
            .filter { $0.photo.photos.count >= Self.maxPhotos }
            .map { _ in RecordAlert.photoLimitReached.message }
            .asSignal(onErrorSignalWith: .empty())

        let setPhotosMutation = input.addPhotos.asObservable()
            .withLatestFrom(state) { newPhotos, current -> Mutation in
                let combined = current.photo.photos + newPhotos
                return .setPhotos(Array(combined.prefix(Self.maxPhotos)))
            }
            .share()

        let deletePhotoMutation = input.deleteCurrentPhoto.asObservable()
            .withLatestFrom(state)
            .filter { !$0.photo.photos.isEmpty }
            .map { Mutation.deletePhoto($0.photo.currentPage) }
            .share()

        let setCaptionMutation = input.captionChanged.asObservable()
            .map { RecordCaptionValidator.truncate($0) }
            .map { Mutation.setCaption($0) }

        let setPageMutation = input.currentPageChanged.asObservable()
            .map { Mutation.setPage($0) }

        let clearLocationMutation = input.clearLocationTap.asObservable()
            .map { Mutation.setLocation(nil, nil) }

        let applySuggestionMutation = input.selectSuggestedLocation.asObservable()
            .map { Mutation.applySuggestion($0) }

        let searchedLocationMutation = input.searchedLocation.asObservable()
            .map { Mutation.setSearchedLocation($0.coordinate, $0.name) }

        let suggestionsMutation = Observable.merge(setPhotosMutation, deletePhotoMutation)
            .withLatestFrom(state) { _, current in current.photo.photos }
            .flatMapLatest { [weak self] photos -> Observable<[SuggestedLocation]> in
                guard let self = self else { return .empty() }
                return Observable.create { observer in
                    self.locationSuggestionUseCase.resolve(from: photos) { suggestions in
                        observer.onNext(suggestions)
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            }
            .map { Mutation.setSuggestions($0) }

        Observable.merge([
            setPhotosMutation,
            deletePhotoMutation,
            setCaptionMutation,
            setPageMutation,
            clearLocationMutation,
            applySuggestionMutation,
            searchedLocationMutation,
            suggestionsMutation
        ])
        .subscribe(onNext: { mutation in
            state.accept(Self.reduce(state.value, mutation))
        })
        .disposed(by: disposeBag)

        let drivenState = state.asDriver()

        let saveResult = input.recordTap.asObservable()
            .withLatestFrom(state)
            .filter { s in
                let trimmed = RecordCaptionValidator.trimmed(s.form.caption)
                return !s.photo.photos.isEmpty && RecordCaptionValidator.isValid(trimmed)
            }
            .flatMapLatest { [weak self] s -> Observable<Event<Record>> in
                guard let self else { return .empty() }
                let draft = RecordDraft(
                    photoDataList: s.photo.photos,
                    caption: RecordCaptionValidator.trimmed(s.form.caption),
                    locationName: s.location.locationName,
                    coordinate: s.location.coordinate
                )
                return Observable.create { observer in
                    self.saveRecordUseCase.execute(draft: draft) { result in
                        switch result {
                        case .success(let record):
                            observer.onNext(.next(record))
                            observer.onCompleted()
                        case .failure(let error):
                            observer.onNext(.error(error))
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                }
            }
            .share()

        let finish = saveResult
            .compactMap { event -> Record? in
                if case .next(let record) = event { return record }
                return nil
            }
            .asSignal(onErrorSignalWith: .empty())

        let saveError = saveResult
            .compactMap { event -> AlertMessage? in
                if case .error = event {
                    return AlertMessage(title: AppStrings.Record.createErrorTitle, message: AppStrings.Record.createErrorMessage)
                }
                return nil
            }
            .asSignal(onErrorSignalWith: .empty())

        let photoDeleted = deletePhotoMutation
            .compactMap { mutation -> Int? in
                if case .deletePhoto(let index) = mutation { return index }
                return nil
            }
            .observe(on: MainScheduler.asyncInstance)
            .asSignal(onErrorSignalWith: .empty())

        return Output(
            state: drivenState,
            requestCamera: requestCamera,
            requestGallery: requestGallery,
            showAlert: Signal.merge(overLimitAlert, saveError),
            finish: finish,
            photoDeleted: photoDeleted
        )
    }
}
