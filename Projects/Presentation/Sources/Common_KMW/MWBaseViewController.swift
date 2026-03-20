//
//  MWBaseViewController.swift
//  Presentation
//
//  Created by 김민우 on 3/20/26.
//

import UIKit
import RxSwift

class MWBaseViewController<VM: MWViewModelType>: UIViewController {
    let viewModel: VM
    var disposeBag = DisposeBag()
    
    init(viewModel: VM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        bindViewModel()
    }
    
    func setupUI() { }
    func setupLayout() { }
    func bindViewModel() { }
}
