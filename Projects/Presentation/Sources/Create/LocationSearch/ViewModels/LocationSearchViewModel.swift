//
//  LocationSearchViewModel.swift
//  Presentation
//
//  Created by 서정원 on 3/24/26.
//

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
        let dismiss: Signal<Void>
    }

    public init() {}

    public func transform(input: Input) -> Output {
        let results = Driver<[LocationSearchItem]>.just([])
        let selected = Driver<LocationSearchItem?>.just(nil)
        let dismiss = input.selectTap

        return Output(
            searchResults: results,
            selectedItem: selected,
            dismiss: dismiss
        )
    }
}

public struct LocationSearchItem: Equatable {
    public let name: String
    public let address: String
    public let latitude: Double
    public let longitude: Double
}
