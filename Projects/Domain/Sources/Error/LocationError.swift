//
//  LocationError.swift
//  Domain
//
//  Created by 서정원 on 3/22/26.
//

import Foundation

public enum LocationError: LocalizedError {
    case denied
    case invalidCoordinate
    case fetchFailed

    public var errorDescription: String? {
        switch self {
        case .denied: return "위치 접근 권한이 거부되었습니다."
        case .invalidCoordinate: return "유효하지 않은 좌표를 수신했습니다."
        case .fetchFailed: return "현재 위치를 가져오는 데 실패했습니다."
        }
    }
}
