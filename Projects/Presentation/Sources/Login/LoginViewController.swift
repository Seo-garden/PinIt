//
//  LoginViewController.swift
//  Presentation
//
//  Created by 김민우 on 3/20/26.
//

import UIKit
import RxCocoa
import RxSwift


// MARK: viewcontroller
@MainActor
public final class LoginViewController: MWBaseViewController<LoginViewModel> {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let heroStackView = UIStackView()
    private let formStackView = UIStackView()
    private let iconContainerView = UIView()
    private let formCardView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)

    public override init(viewModel: LoginViewModel = LoginViewModel()) {
        super.init(viewModel: viewModel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupUI() {
        view.backgroundColor = UIColor(red: 245 / 255, green: 246 / 255, blue: 250 / 255, alpha: 1)
        title = "로그인"
        navigationItem.largeTitleDisplayMode = .never

        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive

        iconContainerView.backgroundColor = UIColor(red: 24 / 255, green: 119 / 255, blue: 242 / 255, alpha: 1)
        iconContainerView.layer.cornerRadius = 84 / 2
        iconContainerView.layer.shadowColor = UIColor(red: 24 / 255, green: 119 / 255, blue: 242 / 255, alpha: 0.28).cgColor
        iconContainerView.layer.shadowOpacity = 1
        iconContainerView.layer.shadowRadius = 28
        iconContainerView.layer.shadowOffset = CGSize(width: 0, height: 14)

        iconImageView.image = UIImage(systemName: "person.crop.circle.badge.checkmark")
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit

        titleLabel.text = "로그인"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center

        configureTextField(
            emailTextField,
            placeholder: "이메일",
            keyboardType: .emailAddress,
            isSecureTextEntry: false,
            textContentType: .emailAddress
        )
        configureTextField(
            passwordTextField,
            placeholder: "비밀번호",
            keyboardType: .default,
            isSecureTextEntry: true,
            textContentType: .password
        )

        updateLoginButtonAppearance(isLoading: false)
        loginButton.isEnabled = false
        loginButton.alpha = 0.58

        heroStackView.axis = .vertical
        heroStackView.spacing = 18
        heroStackView.alignment = .center

        formStackView.axis = .vertical
        formStackView.spacing = 12
        formStackView.alignment = .fill

        formCardView.backgroundColor = .white
        formCardView.layer.cornerRadius = 28
        formCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        formCardView.layer.shadowOpacity = 1
        formCardView.layer.shadowRadius = 20
        formCardView.layer.shadowOffset = CGSize(width: 0, height: 10)

        heroStackView.addArrangedSubview(iconContainerView)
        heroStackView.addArrangedSubview(titleLabel)

        iconContainerView.addSubview(iconImageView)

        [emailTextField, passwordTextField, loginButton]
            .forEach { formStackView.addArrangedSubview($0) }

        formCardView.addSubview(formStackView)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(heroStackView)
        contentView.addSubview(formCardView)
    }

    override func setupLayout() {
        [
            scrollView,
            contentView,
            heroStackView,
            formCardView,
            formStackView,
            iconContainerView,
            iconImageView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),

            heroStackView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 48),
            heroStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            heroStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            iconContainerView.widthAnchor.constraint(equalToConstant: 84),
            iconContainerView.heightAnchor.constraint(equalToConstant: 84),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 42),
            iconImageView.heightAnchor.constraint(equalToConstant: 42),

            formCardView.topAnchor.constraint(equalTo: heroStackView.bottomAnchor, constant: 32),
            formCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            formCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            formCardView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -28),

            formStackView.topAnchor.constraint(equalTo: formCardView.topAnchor, constant: 22),
            formStackView.leadingAnchor.constraint(equalTo: formCardView.leadingAnchor, constant: 24),
            formStackView.trailingAnchor.constraint(equalTo: formCardView.trailingAnchor, constant: -24),
            formStackView.bottomAnchor.constraint(equalTo: formCardView.bottomAnchor, constant: -22),

            emailTextField.heightAnchor.constraint(equalToConstant: 58),
            passwordTextField.heightAnchor.constraint(equalToConstant: 58),
            loginButton.heightAnchor.constraint(equalToConstant: 58)
        ])
    }

    override func bindViewModel() {
        let tapGesture = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .bind(with: self) { owner, _ in
                owner.view.endEditing(true)
            }
            .disposed(by: disposeBag)

        emailTextField.rx.controlEvent(.editingDidEndOnExit)
            .bind(with: self) { owner, _ in
                owner.passwordTextField.becomeFirstResponder()
            }
            .disposed(by: disposeBag)

        passwordTextField.rx.controlEvent(.editingDidEndOnExit)
            .bind(with: self) { owner, _ in
                owner.passwordTextField.resignFirstResponder()
                owner.loginButton.sendActions(for: .touchUpInside)
            }
            .disposed(by: disposeBag)

        let input = LoginViewModel.Input(
            emailText: emailTextField.rx.text.orEmpty.asSignal(onErrorJustReturn: ""),
            passwordText: passwordTextField.rx.text.orEmpty.asSignal(onErrorJustReturn: ""),
            loginTap: loginButton.rx.tap.asSignal()
        )

        let output = viewModel.transform(input: input)

        output.isLoginEnabled
            .drive(onNext: { [weak self] isEnabled in
                self?.loginButton.isEnabled = isEnabled
                self?.loginButton.alpha = isEnabled ? 1 : 0.58
            })
            .disposed(by: disposeBag)

        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                guard let self else { return }
                self.updateLoginButtonAppearance(isLoading: isLoading)
                self.emailTextField.isEnabled = !isLoading
                self.passwordTextField.isEnabled = !isLoading
            })
            .disposed(by: disposeBag)

        output.errorMessage
            .emit(onNext: { [weak self] message in
                self?.presentAlert(title: "로그인 실패", message: message)
            })
            .disposed(by: disposeBag)

        output.loginSucceeded
            .emit(onNext: { [weak self] message in
                self?.presentAlert(title: "로그인", message: message)
            })
            .disposed(by: disposeBag)
    }

    private func configureTextField(
        _ textField: UITextField,
        placeholder: String,
        keyboardType: UIKeyboardType,
        isSecureTextEntry: Bool,
        textContentType: UITextContentType?
    ) {
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
        textField.keyboardType = keyboardType
        textField.isSecureTextEntry = isSecureTextEntry
        textField.textContentType = textContentType
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.borderStyle = .none
        textField.backgroundColor = UIColor(red: 245 / 255, green: 246 / 255, blue: 250 / 255, alpha: 1)
        textField.layer.cornerRadius = 20
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(red: 229 / 255, green: 232 / 255, blue: 238 / 255, alpha: 1).cgColor
        textField.font = .systemFont(ofSize: 16, weight: .medium)
        textField.leftView = makeTextFieldPaddingView()
        textField.leftViewMode = .always
        textField.returnKeyType = isSecureTextEntry ? .go : .next
    }

    private func updateLoginButtonAppearance(isLoading: Bool) {
        var configuration = UIButton.Configuration.filled()
        configuration.title = isLoading ? "로그인 중..." : "로그인"
        configuration.baseBackgroundColor = UIColor(red: 24 / 255, green: 119 / 255, blue: 242 / 255, alpha: 1)
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 20, bottom: 18, trailing: 20)
        configuration.showsActivityIndicator = isLoading
        configuration.imagePadding = 8
        loginButton.configuration = configuration
        loginButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
    }

    private func makeTextFieldPaddingView() -> UIView {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 10))
        return paddingView
    }

    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}


#Preview {
    LoginViewController()
}
