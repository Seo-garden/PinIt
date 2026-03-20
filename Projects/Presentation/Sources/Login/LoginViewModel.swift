//
//  LoginViewModel.swift
//  Presentation
//
//  Created by 김민우 on 3/20/26.
//

import Foundation
import RxCocoa
import RxRelay
import RxSwift
import OSLog


// MARK: object
@MainActor
public final class LoginViewModel: MWBaseViewModel, MWViewModelType {
    private let logger = Logger()

    public override init() {
        super.init()
    }

    public struct Input {
        let emailText: Signal<String>
        let passwordText: Signal<String>
        let loginTap: Signal<Void>
    }

    public struct Output {
        let isLoginEnabled: Driver<Bool>
        let isLoading: Driver<Bool>
        let errorMessage: Signal<String>
        let loginSucceeded: Signal<String>
    }

    public func transform(input: Input) -> Output {
        let emailRelay = BehaviorRelay<String>(value: "")
        let passwordRelay = BehaviorRelay<String>(value: "")
        let isLoadingRelay = BehaviorRelay<Bool>(value: false)
        let errorMessageRelay = PublishRelay<String>()
        let loginSucceededRelay = PublishRelay<String>()

        input.emailText
            .emit(to: emailRelay)
            .disposed(by: disposeBag)

        input.passwordText
            .emit(to: passwordRelay)
            .disposed(by: disposeBag)

        let credentials = Observable
            .combineLatest(emailRelay.asObservable(), passwordRelay.asObservable())
            .share(replay: 1, scope: .whileConnected)

        let isLoginEnabled = Observable
            .combineLatest(credentials, isLoadingRelay.asObservable()) { credentials, isLoading in
                Self.isValidEmail(credentials.0) && Self.isValidPassword(credentials.1) && !isLoading
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        input.loginTap.asObservable()
            .withLatestFrom(credentials)
            .subscribe(onNext: { [weak self] email, password in
                guard let self else { return }

                guard Self.isValidEmail(email) else {
                    errorMessageRelay.accept("올바른 이메일 형식을 입력해주세요.")
                    return
                }

                guard Self.isValidPassword(password) else {
                    errorMessageRelay.accept("비밀번호는 8자 이상 입력해주세요.")
                    return
                }

                isLoadingRelay.accept(true)
                logger.log("Login requested for \(email, privacy: .private(mask: .hash))")

                Observable
                    .just("로그인 준비가 완료되었습니다.")
                    .delay(.milliseconds(300), scheduler: MainScheduler.instance)
                    .subscribe(onNext: { message in
                        isLoadingRelay.accept(false)
                        loginSucceededRelay.accept(message)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)

        return Output(
            isLoginEnabled: isLoginEnabled,
            isLoading: isLoadingRelay.asDriver(),
            errorMessage: errorMessageRelay.asSignal(),
            loginSucceeded: loginSucceededRelay.asSignal()
        )
    }

    private static func isValidEmail(_ email: String) -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedEmail.isEmpty == false else { return false }

        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return trimmedEmail.range(of: emailRegex, options: .regularExpression) != nil
    }

    private static func isValidPassword(_ password: String) -> Bool {
        password.count >= 8
    }
}
