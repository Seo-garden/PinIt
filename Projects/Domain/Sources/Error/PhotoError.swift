//
//  PhotoError.swift
//  Domain
//
//  Created by 서정원 on 3/13/26.
//

import Foundation

public enum PhotoError: LocalizedError {
    case accessDenied
    case unavailable
    case loadFailed

    public var errorDescription: String? {
        switch self {
        case .accessDenied: return "사진 접근 권한이 거부되었습니다."
        case .unavailable: return "이 기기에서는 해당 기능을 사용할 수 없습니다."
        case .loadFailed: return "선택한 사진을 불러오는 데 실패했습니다."
        }
    }
}
