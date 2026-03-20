//
//  MWBaseViewModel.swift
//  Presentation
//
//  Created by 김민우 on 3/20/26.
//

import RxSwift

internal class MWBaseViewModel {
    var disposeBag = DisposeBag()
    
    deinit {
        disposeBag = DisposeBag()
    }
}
