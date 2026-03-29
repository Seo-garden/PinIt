//
//  LocationSearchViewModel.swift
//  Presentation
//
//  Created by 서정원 on 3/24/26.
//

import Domain
import RxCocoa
import RxSwift

public final class LocationSearchViewModel: ViewModelType {
    public struct Input {
        let searchText: Signal<String>
        let selectItem: Signal<Int>
        let selectTap: Signal<Void>
    }

    public struct Output {
        let searchResults: Driver<[LocationSearchItem]>
        let selectedItem: Driver<LocationSearchItem?>
        let errorMessage: Signal<String>
        let dismiss: Signal<Void>
    }

    private let searchLocationUseCase: SearchLocationUseCase

    public init(searchLocationUseCase: SearchLocationUseCase) {
        self.searchLocationUseCase = searchLocationUseCase
    }

    private let errorRelay = PublishRelay<String>()

    public func transform(input: Input) -> Output {
        let results = input.searchText
            .flatMapLatest { [weak self] query -> Signal<[LocationSearchItem]> in
                guard let self else { return .just([]) }
                guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    return .just([])
                }
                return self.searchLocations(query: query)
                    .asSignal(onErrorJustReturn: [])
            }
            .asDriver(onErrorJustReturn: [])

        let resultsRelay = BehaviorRelay<[LocationSearchItem]>(value: [])

        let trackedResults = results
            .do(onNext: { resultsRelay.accept($0) })

        let selected = input.selectItem
            .map { index -> LocationSearchItem? in
                let items = resultsRelay.value
                guard index >= 0, index < items.count else { return nil }
                return items[index]
            }
            .asDriver(onErrorJustReturn: nil)

        let dismiss = input.selectTap

        return Output(
            searchResults: trackedResults,
            selectedItem: selected,
            errorMessage: errorRelay.asSignal(),
            dismiss: dismiss
        )
    }

    private func searchLocations(query: String) -> Observable<[LocationSearchItem]> {
        Observable.create { [weak self] observer in
            self?.searchLocationUseCase.execute(query: query) { result in
                switch result {
                case .success(let locations):
                    let items = locations.map {
                        LocationSearchItem(
                            name: $0.name,
                            address: $0.address,
                            latitude: $0.coordinate.latitude,
                            longitude: $0.coordinate.longitude
                        )
                    }
                    observer.onNext(items)
                    observer.onCompleted()
                case .failure(let error):
                    self?.errorRelay.accept(error.localizedDescription)
                    observer.onNext([])
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}
