//
//  SettingViewModel.swift
//  Presentation
//
//  Created by 서정원 on 4/7/26.
//

import Domain
import Foundation
import RxCocoa
import RxRelay
import RxSwift

public final class SettingViewModel: ViewModelType {
    private let fetchCurrentUserUseCase: FetchCurrentUserUseCase
    private let signOutUseCase: SignOutUseCase
    private let deleteAccountUseCase: DeleteAccountUseCase
    private let disposeBag = DisposeBag()

    public init(
        fetchCurrentUserUseCase: FetchCurrentUserUseCase,
        signOutUseCase: SignOutUseCase,
        deleteAccountUseCase: DeleteAccountUseCase
    ) {
        self.fetchCurrentUserUseCase = fetchCurrentUserUseCase
        self.signOutUseCase = signOutUseCase
        self.deleteAccountUseCase = deleteAccountUseCase
    }

    public struct Input {
        let viewDidLoad: Signal<Void>
        let logoutTap: Signal<Void>
        let deleteAccountTap: Signal<Void>
    }

    public struct Output {
        let name: Driver<String>
        let email: Driver<String>
        let logoutSucceeded: Signal<Void>
        let deleteAccountSucceeded: Signal<Void>
        let errorMessage: Signal<String>
    }

    public func transform(input: Input) -> Output {
        let displayNameRelay = BehaviorRelay<String>(value: "User")
        let emailRelay = BehaviorRelay<String>(value: "")
        let logoutSucceededRelay = PublishRelay<Void>()
        let deleteAccountSucceededRelay = PublishRelay<Void>()
        let errorMessageRelay = PublishRelay<String>()

        input.viewDidLoad
            .emit(onNext: { [weak self] in
                guard let self else { return }
                let user = self.fetchCurrentUserUseCase.execute()
                if let name = user.displayName, !name.isEmpty {
                    displayNameRelay.accept(name)
                }
                if let email = user.email {
                    emailRelay.accept(email)
                }
            })
            .disposed(by: disposeBag)

        input.logoutTap
            .emit(onNext: { [weak self] in
                guard let self else { return }
                self.signOutUseCase.execute { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            logoutSucceededRelay.accept(())
                        case .failure:
                            errorMessageRelay.accept("로그아웃에 실패했습니다. 다시 시도해주세요.")
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        input.deleteAccountTap
            .emit(onNext: { [weak self] in
                guard let self else { return }
                self.deleteAccountUseCase.execute { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            deleteAccountSucceededRelay.accept(())
                        case .failure:
                            errorMessageRelay.accept("회원탈퇴에 실패했습니다. 다시 시도해주세요.")
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        return Output(
            name: displayNameRelay.asDriver(),
            email: emailRelay.asDriver(),
            logoutSucceeded: logoutSucceededRelay.asSignal(),
            deleteAccountSucceeded: deleteAccountSucceededRelay.asSignal(),
            errorMessage: errorMessageRelay.asSignal()
        )
    }
}
