//
//  LocationFieldView.swift
//  Presentation
//
//  Created by 서정원 on 3/12/26.
//

import RxCocoa
import RxRelay
import RxSwift
import UIKit

final class LocationFieldView: UIView {
    private let clearRelay = PublishRelay<Void>()

    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .secondaryLabel
        button.isHidden = true
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(clearButton)
        [container, titleLabel, clearButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        clearButton.addTarget(self, action: #selector(clearAction), for: .touchUpInside)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 54),

            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            clearButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            clearButton.widthAnchor.constraint(equalToConstant: 28),
            clearButton.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: clearButton.leadingAnchor, constant: -8)
        ])
    }

    func configure(text: String?, showsClear: Bool) {
        titleLabel.text = text?.isEmpty == false ? text : "장소를 채워보세요!"
        titleLabel.textColor = text?.isEmpty == false ? .label : .secondaryLabel
        clearButton.isHidden = !showsClear
    }
    
    @objc private func clearAction() { clearRelay.accept(()) }

    var clear: Signal<Void> { clearRelay.asSignal() }
}
