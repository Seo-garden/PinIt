//
//  BaseViewController.swift
//  Presentation
//
//  Created by 서정원 on 3/20/26.
//

import RxSwift
import UIKit

open class BaseViewController<ViewModel: ViewModelType>: UIViewController {

    let viewModel: ViewModel
    var disposeBag = DisposeBag()

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        bind()
    }

    open func setupUI() {
        view.backgroundColor = .systemBackground
    }
    
    open func setupLayout() {}
    open func bind() {}
}
