//
//  DetailRecordViewModel.swift
//  Presentation
//
//  Created by 서정원 on 4/2/26.
//

import Domain
import Foundation
import RxCocoa
import RxRelay
import RxSwift

public final class DetailRecordViewModel: ViewModelType {
    private let record: Record
    private let deleteRecordUseCase: DeleteRecordUseCase
    private let updateRecordCaptionUseCase: UpdateRecordCaptionUseCase
    private var disposeBag = DisposeBag()

    public init(
        record: Record,
        deleteRecordUseCase: DeleteRecordUseCase,
        updateRecordCaptionUseCase: UpdateRecordCaptionUseCase
    ) {
        self.record = record
        self.deleteRecordUseCase = deleteRecordUseCase
        self.updateRecordCaptionUseCase = updateRecordCaptionUseCase
    }

    // MARK: - State

    public struct PhotoState: Equatable {
        public var photos: [PhotoData]
        public var currentPage: Int = 0
    }

    public struct FormState: Equatable {
        public var caption: String
        public var originalCaption: String
    }

    public struct LocationState: Equatable {
        public var locationName: String?
        public var coordinate: Coordinate?
    }

    public struct State: Equatable {
        public var photo: PhotoState
        public var form: FormState
        public var location: LocationState

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

        public var isCaptionModified: Bool {
            let trimmed = RecordCaptionValidator.trimmed(form.caption)
            return trimmed != form.originalCaption
        }
    }

    // MARK: - Mutation

    private enum Mutation {
        case setCaption(String)
        case setPage(Int)
    }

    private static func reduce(_ state: State, _ mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setCaption(let caption):
            newState.form.caption = caption
        case .setPage(let page):
            newState.photo.currentPage = page
        }
        return newState
    }

    // MARK: - Input / Output

    public struct Input {
        public let captionChanged: Signal<String>
        public let currentPageChanged: Signal<Int>
        public let backTap: Signal<Void>
        public let deleteTap: Signal<Void>
    }

    public struct Output {
        public let state: Driver<State>
        public let showAlert: Signal<AlertMessage>
        public let saved: Signal<Void>
        public let deleted: Signal<Void>
    }

    public func transform(input: Input) -> Output {
        let initialState = State(
            photo: PhotoState(photos: record.photoDataList),
            form: FormState(
                caption: record.caption,
                originalCaption: record.caption
            ),
            location: LocationState(
                locationName: record.locationName,
                coordinate: record.coordinate
            )
        )

        let state = BehaviorRelay<State>(value: initialState)

        let setCaptionMutation = input.captionChanged.asObservable()
            .map { RecordCaptionValidator.truncate($0) }
            .map { Mutation.setCaption($0) }

        let setPageMutation = input.currentPageChanged.asObservable()
            .map { Mutation.setPage($0) }

        Observable.merge(setCaptionMutation, setPageMutation)
            .subscribe(onNext: { mutation in
                state.accept(Self.reduce(state.value, mutation))
            })
            .disposed(by: disposeBag)

        // MARK: - Back (save if modified, then pop)

        let backWithState = input.backTap.asObservable()
            .withLatestFrom(state)
            .share()

        let backEmptyCaption = backWithState
            .filter { !RecordCaptionValidator.isValid($0.form.caption) }
            .map { _ in AlertMessage(title: AppStrings.Detail.emptyCaptionTitle, message: AppStrings.Detail.emptyCaptionMessage) }
            .asSignal(onErrorSignalWith: .empty())

        let backNoChange = backWithState
            .filter { RecordCaptionValidator.isValid($0.form.caption) && !$0.isCaptionModified }
            .map { _ in () }

        let backSaveResult = backWithState
            .filter { RecordCaptionValidator.isValid($0.form.caption) && $0.isCaptionModified }
            .flatMapLatest { [weak self] currentState -> Observable<Event<Void>> in
                guard let self else { return .empty() }
                let trimmed = RecordCaptionValidator.trimmed(currentState.form.caption)
                return Observable.create { observer in
                    self.updateRecordCaptionUseCase.execute(
                        id: self.record.id,
                        caption: trimmed
                    ) { result in
                        switch result {
                        case .success:
                            observer.onNext(.next(()))
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

        let backSaveSuccess = backSaveResult
            .compactMap { event -> Void? in
                if case .next = event { return () }
                return nil
            }

        let saved = Observable.merge(backNoChange, backSaveSuccess)
            .asSignal(onErrorSignalWith: .empty())

        let saveError = backSaveResult
            .compactMap { event -> AlertMessage? in
                if case .error = event {
                    return AlertMessage(title: AppStrings.Detail.saveFailTitle, message: AppStrings.Detail.saveFailMessage)
                }
                return nil
            }
            .asSignal(onErrorSignalWith: .empty())

        // MARK: - Delete record
        let deleteResult = input.deleteTap.asObservable()
            .flatMapLatest { [weak self] _ -> Observable<Event<Void>> in
                guard let self else { return .empty() }
                return Observable.create { observer in
                    self.deleteRecordUseCase.execute(id: self.record.id) { result in
                        switch result {
                        case .success:
                            observer.onNext(.next(()))
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

        let deleted = deleteResult
            .compactMap { event -> Void? in
                if case .next = event { return () }
                return nil
            }
            .asSignal(onErrorSignalWith: .empty())

        let deleteError = deleteResult
            .compactMap { event -> AlertMessage? in
                if case .error = event {
                    return AlertMessage(title: AppStrings.Detail.deleteFailTitle, message: AppStrings.Detail.deleteFailMessage)
                }
                return nil
            }
            .asSignal(onErrorSignalWith: .empty())

        let showAlert = Signal.merge(backEmptyCaption, saveError, deleteError)

        return Output(
            state: state.asDriver(),
            showAlert: showAlert,
            saved: saved,
            deleted: deleted
        )
    }
}
