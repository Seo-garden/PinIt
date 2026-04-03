//
//  PhotoPermissionError.swift
//  Presentation
//
//  Created by 서정원 on 3/14/26.
//

/// Presentation 계층 전용 권한 에러.
/// 카메라/갤러리 등 시스템 권한 거부 시 UI에서 구체적인 안내를 제공하기 위해 사용합니다.
public enum PermissionSource {
    case camera
    case photoLibrary
}

public enum PhotoPermissionError: Error {
    case denied(source: PermissionSource)
}
