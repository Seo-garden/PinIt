//
//  LoginViewModel.swift
//  Presentation
//
//  Created by 김민우 on 3/20/26.
//

import Foundation
import FirebaseAuth
import RxCocoa
import RxRelay
import RxSwift
import OSLog


// MARK: object
@MainActor
public final class LoginViewModel: MWBaseViewModel, MWViewModelType {
    private let authManagerRepository: any AuthManagerInterface
    private let logger = Logger()

    public init(authManagerRepository: any AuthManagerInterface = AuthManagerRepository()) {
        self.authManagerRepository = authManagerRepository
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

                self.authManagerRepository.signIn(email: email, password: password)
                    .observe(on: MainScheduler.instance)
                    .subscribe(
                        onSuccess: { message in
                            isLoadingRelay.accept(false)
                            loginSucceededRelay.accept("\(message) 계정으로 로그인되었습니다.")
                        },
                        onFailure: { error in
                            self.logger.error("Login failed: \(error.localizedDescription, privacy: .public)")
                            isLoadingRelay.accept(false)
                            errorMessageRelay.accept(Self.makeErrorMessage(from: error))
                        }
                    )
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

    private static func makeErrorMessage(from error: Error) -> String {
        if let authError = error as? AuthManagerRepositoryError {
            return authError.localizedDescription
        }

        guard let errorCode = AuthErrorCode(rawValue: (error as NSError).code) else {
            return "로그인에 실패했습니다. 잠시 후 다시 시도해주세요."
        }

        switch errorCode {
        case .wrongPassword, .invalidCredential:
            return "이메일 또는 비밀번호를 다시 확인해주세요."
        case .invalidEmail:
            return "올바른 이메일 형식을 입력해주세요."
        case .userNotFound:
            return "등록되지 않은 계정입니다."
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        case .tooManyRequests:
            return "요청이 너무 많습니다. 잠시 후 다시 시도해주세요."
        default:
            return "로그인에 실패했습니다. 잠시 후 다시 시도해주세요."
        }
    }

    private static func isValidEmail(_ email: String) -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedEmail.isEmpty == false else { return false }

        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return trimmedEmail.range(of: emailRegex, options: .regularExpression) != nil
    }

    private static func isValidPassword(_ password: String) -> Bool {
        password.count >= 6
    }
}
