//
//  MapViewModel.swift
//  Presentation
//
//  Created by 서정원 on 3/20/26.
//

import Foundation
import Domain
import RxCocoa
import RxSwift

public final class MapViewModel: ViewModelType {
    public struct Input {
        let viewDidAppear: Signal<Void>
        let locateMeTap: Signal<Void>
    }

    public struct Output {
        let centerLocation: Signal<Coordinate>
        let panToLocation: Signal<Coordinate>
        let showLocationDeniedAlert: Signal<Void>
    }

    private let fetchUserLocationUseCase: FetchUserLocationUseCase

    public init(fetchUserLocationUseCase: FetchUserLocationUseCase) {
        self.fetchUserLocationUseCase = fetchUserLocationUseCase
    }

    public func transform(input: Input) -> Output {
        let initialLocation = input.viewDidAppear
            .flatMapLatest { [weak self] _ -> Signal<Coordinate> in
                guard let self else { return .just(Coordinate(MapRegionHelper.defaultLocation)!) }
                return self.fetchResultSignal()
                    .map { result -> Coordinate in
                        switch result {
                        case .success(let coordinate): return coordinate
                        case .failure: return Coordinate(MapRegionHelper.defaultLocation)!
                        }
                    }
            }

        let locateMeResult = input.locateMeTap
            .throttle(.seconds(1), latest: false)
            .flatMapLatest { [weak self] _ -> Signal<Result<Coordinate, LocationError>> in
                guard let self else { return .empty() }
                return self.fetchResultSignal()
            }

        let locateMeLocation = locateMeResult.compactMap { result -> Coordinate? in
            guard case .success(let coordinate) = result else { return nil }
            return coordinate
        }

        let showLocationDeniedAlert = locateMeResult.compactMap { result -> Void? in
            guard case .failure = result else { return nil }
            return ()
        }

        return Output(
            centerLocation: initialLocation,
            panToLocation: locateMeLocation,
            showLocationDeniedAlert: showLocationDeniedAlert
        )
    }

    private func fetchResultSignal() -> Signal<Result<Coordinate, LocationError>> {
        Single<Result<Coordinate, LocationError>>.create { [weak self] single in
            guard let self else {
                single(.success(.failure(.fetchFailed)))
                return Disposables.create()
            }
            self.fetchUserLocationUseCase.execute { result in
                single(.success(result))
            }
            return Disposables.create()
        }
        .asSignal(onErrorJustReturn: .failure(.fetchFailed))
    }
}
