//
//  CaptionInputView.swift
//  Presentation
//
//  Created by 서정원 on 3/12/26.
//

import RxRelay
import RxSwift
import UIKit

final class CaptionInputView: UIView {
    private let textRelay = PublishRelay<String>()

    private let maxLength: Int

    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 18
        textView.textContainerInset = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        textView.isScrollEnabled = true
        textView.alwaysBounceVertical = true
        textView.showsVerticalScrollIndicator = true
        textView.autocapitalizationType = .none
        return textView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = " 기록을 표현하는 한 문장을 작성해보세요!"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        return label
    }()
    

    init(maxLength: Int) {
        self.maxLength = maxLength
        super.init(frame: .zero)
        setupUI()
        setupLayout()
        updateCount(text: "")
        textRelay.accept("")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(textView)
        textView.addSubview(placeholderLabel)
        [textView, placeholderLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        textView.delegate = self
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor),
            textView.heightAnchor.constraint(equalToConstant: 150),

            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 14),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -14),
        ])
    }

    // MARK: - Public
    func setText(_ text: String) {
        if textView.text != text {
            textView.text = text
            updateCount(text: text)
            textRelay.accept(text)
        }
    }

    // MARK: - Rx
    func textChanges() -> Observable<String> {
        textRelay.asObservable()
    }

    private func updateCount(text: String) {
        placeholderLabel.isHidden = !text.isEmpty
    }
}

// MARK: - UITextViewDelegate
extension CaptionInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateCount(text: textView.text)
        textRelay.accept(textView.text)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let current = textView.text, let range = Range(range, in: current) else { return true }
        let updated = current.replacingCharacters(in: range, with: text)
        return updated.count <= maxLength
    }
}
