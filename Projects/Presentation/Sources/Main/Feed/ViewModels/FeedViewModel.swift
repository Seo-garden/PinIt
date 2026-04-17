//
//  FeedViewModel.swift
//  Presentation
//
//  Created by 서정원 on 3/20/26.
//

import Domain
import Foundation
import RxCocoa
import RxRelay
import RxSwift

public final class FeedViewModel: ViewModelType {
    private let fetchAllRecordsUseCase: FetchAllRecordsUseCase
    private var disposeBag = DisposeBag()

    public init(fetchAllRecordsUseCase: FetchAllRecordsUseCase) {
        self.fetchAllRecordsUseCase = fetchAllRecordsUseCase
    }

    public struct Input {
        public let viewDidAppear: Signal<Void>
        public let selectRecord: Signal<Int>
        public let searchText: Driver<String>
        public let sortOption: Driver<FeedSortOption>
    }

    public struct Output {
        public let records: Driver<[Record]>
        public let navigateToDetail: Signal<Record>
    }

    public func transform(input: Input) -> Output {
        let recordsRelay = BehaviorRelay<[Record]>(value: [])

        input.viewDidAppear.asObservable()
            .flatMapLatest { [weak self] _ -> Observable<[Record]> in
                guard let self else { return .empty() }
                return Observable.create { observer in
                    self.fetchAllRecordsUseCase.execute { result in
                        if case .success(let records) = result {
                            observer.onNext(records)
                        }
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            }
            .bind(to: recordsRelay)
            .disposed(by: disposeBag)

        let displayedRecords = Driver.combineLatest(
            recordsRelay.asDriver(),
            input.searchText.startWith(""),
            input.sortOption.startWith(.dateDescending)
        ) { records, query, sort -> [Record] in
            let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
            let filtered = trimmed.isEmpty
                ? records
                : records.filter {
                    $0.locationTitle.localizedCaseInsensitiveContains(trimmed)
                }
            return sort.sort(filtered)
        }

        let navigateToDetail = input.selectRecord.asObservable()
            .withLatestFrom(displayedRecords.asObservable()) { index, records -> Record? in
                guard index < records.count else { return nil }
                return records[index]
            }
            .compactMap { $0 }
            .asSignal(onErrorSignalWith: .empty())

        return Output(
            records: displayedRecords,
            navigateToDetail: navigateToDetail
        )
    }
}
