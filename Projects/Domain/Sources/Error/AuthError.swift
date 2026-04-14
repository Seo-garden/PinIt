//
//  AuthError.swift
//  Domain
//
//  Created by 서정원 on 4/6/26.
//

import Foundation

public enum AuthError: LocalizedError {
    case firebaseNotConfigured
    case missingUserEmail
    case wrongCredentials
    case invalidEmail
    case userNotFound
    case network
    case tooManyRequests
    case unknown

    public var errorDescription: String? {
        switch self {
        case .firebaseNotConfigured:
            return "Firebase 설정이 완료되지 않았습니다. Data 타깃 리소스에 GoogleService-Info.plist를 추가해주세요."
        case .missingUserEmail:
            return "로그인한 사용자 정보를 확인할 수 없습니다."
        case .wrongCredentials:
            return "이메일 또는 비밀번호를 다시 확인해주세요."
        case .invalidEmail:
            return "올바른 이메일 형식을 입력해주세요."
        case .userNotFound:
            return "등록되지 않은 계정입니다."
        case .network:
            return "네트워크 연결을 확인해주세요."
        case .tooManyRequests:
            return "요청이 너무 많습니다. 잠시 후 다시 시도해주세요."
        case .unknown:
            return "로그인에 실패했습니다. 잠시 후 다시 시도해주세요."
        }
    }
}
