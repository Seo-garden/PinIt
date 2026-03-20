//
//  MWViewModelType.swift
//  Presentation
//
//  Created by 김민우 on 3/20/26.
//

protocol MWViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
