//
//  ViewModelType.swift
//  Presentation
//
//  Created by 서정원 on 3/20/26.
//

public protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}
