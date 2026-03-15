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


public final class CreateRecordViewModel {

    // MARK: - Constants

    public static let maxPhotos = 5

    // MARK: - Dependencies

    private let locationSuggestionUseCase: LocationSuggestionUseCase
    private let disposeBag = DisposeBag()

    // MARK: - Init

    public init(locationSuggestionUseCase: LocationSuggestionUseCase) {
        self.locationSuggestionUseCase = locationSuggestionUseCase
    }

    // MARK: - Sub-States

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

        public mutating func reset() {
            suggestions = []
            locationName = nil
            coordinate = nil
        }

        public static func == (lhs: LocationState, rhs: LocationState) -> Bool {
            lhs.locationName == rhs.locationName
                && lhs.coordinate == rhs.coordinate
                && lhs.suggestions == rhs.suggestions
        }
    }

    // MARK: - State (서브 구조체 조합)

    public struct State: Equatable {
        public var photo: PhotoState = .init()
        public var form: FormState = .init()
        public var location: LocationState = .init()

        // MARK: - Derived (VC는 이 값을 그대로 바인딩만 하면 됨)

        public var hasPhotos: Bool {
            !photo.photos.isEmpty
        }

        public var pageBadgeText: String {
            hasPhotos
                ? "\(photo.currentPage + 1) / \(photo.photos.count)"
                : "0 / 0"
        }

        public var captionCountText: String {
            "\(form.caption.count) / \(MemoryCaptionValidator.maxLength)"
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
        case setSuggestions([SuggestedLocation])
        case applySuggestion(Int)
    }

    // MARK: - Reduce (순수 함수)

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
        case .setSuggestions(let suggestions):
            newState.location.suggestions = suggestions
            if suggestions.isEmpty {
                newState.location.coordinate = nil
                newState.location.locationName = nil
            } else if newState.location.locationName == nil {
                newState.location.coordinate = suggestions[0].coordinate
                newState.location.locationName = suggestions[0].title
            }
        case .applySuggestion(let index):
            if index < newState.location.suggestions.count {
                let suggestion = newState.location.suggestions[index]
                newState.location.coordinate = suggestion.coordinate
                newState.location.locationName = suggestion.title
            }
        }

        // 사진이 비면 위치 정보 초기화 (setPhotos / deletePhoto 공통)
        if newState.photo.photos.isEmpty {
            newState.location.reset()
        }

        return newState
    }

    // MARK: - Input / Output

    public struct Input {
        public let takePhotoTap: Signal<Void>
        public let galleryTap: Signal<Void>
        public let addPhotos: Signal<[PhotoData]>
        public let deleteCurrentPhoto: Signal<Void>
        public let captionChanged: Signal<String>
        public let currentPageChanged: Signal<Int>
        public let clearLocationTap: Signal<Void>
        public let selectSuggestedLocation: Signal<Int>
        public let recordTap: Signal<Void>
    }

    public struct Output {
        public let state: Driver<State>
        public let requestCamera: Signal<Void>
        public let requestGallery: Signal<Int>
        public let showAlert: Signal<AlertMessage>
        public let finish: Signal<MemoryDraft>
        public let photoDeleted: Signal<Int>
    }

    // MARK: - Transform

    public func transform(input: Input) -> Output {
        // 단일 상태 저장소: BehaviorRelay만 사용, scan 없음
        let state = BehaviorRelay<State>(value: State())

        // 1. Read-only outputs (상태를 읽기만 하고 변경하지 않음)
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

        // 2. Mutations
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
            .map { MemoryCaptionValidator.truncate($0) }
            .map { Mutation.setCaption($0) }

        let setPageMutation = input.currentPageChanged.asObservable()
            .map { Mutation.setPage($0) }

        let clearLocationMutation = input.clearLocationTap.asObservable()
            .map { Mutation.setLocation(nil, nil) }

        let applySuggestionMutation = input.selectSuggestedLocation.asObservable()
            .map { Mutation.applySuggestion($0) }

        // Fetch suggestions when photos change (add or delete)
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

        // 3. 단일 상태 갱신: merge → reduce → relay.accept
        Observable.merge([
            setPhotosMutation,
            deletePhotoMutation,
            setCaptionMutation,
            setPageMutation,
            clearLocationMutation,
            applySuggestionMutation,
            suggestionsMutation
        ])
        .subscribe(onNext: { mutation in
            state.accept(Self.reduce(state.value, mutation))
        })
        .disposed(by: disposeBag)

        // 4. UI 바인딩용 Driver (BehaviorRelay는 초기값을 자동 replay)
        let drivenState = state.asDriver()

        // 5. Finish — state relay가 유일한 상태 저장소이므로 항상 최신 상태 보장
        let finish = input.recordTap.asObservable()
            .withLatestFrom(state)
            .filter { s in
                let trimmed = MemoryCaptionValidator.trimmed(s.form.caption)
                return !s.photo.photos.isEmpty && MemoryCaptionValidator.isValid(trimmed)
            }
            .map { s in
                MemoryDraft(
                    photoDataList: s.photo.photos,
                    caption: MemoryCaptionValidator.trimmed(s.form.caption),
                    locationName: s.location.locationName,
                    coordinate: s.location.coordinate
                )
            }
            .asSignal(onErrorSignalWith: .empty())

        // 6. Side effect for UI (CollectionView deletion animation sync)
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
            showAlert: overLimitAlert,
            finish: finish,
            photoDeleted: photoDeleted
        )
    }
}
