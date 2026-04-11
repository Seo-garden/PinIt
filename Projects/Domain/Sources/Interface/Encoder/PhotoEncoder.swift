//
//  PhotoEncoder.swift
//  Domain
//
//  Created by 서정원 on 4/10/26.
//

import Foundation

public protocol PhotoEncoder: Sendable {
    /// 입력 바이너리가 JPEG 가 아니라면 JPEG 로 변환해서 반환합니다.
    /// 이미 JPEG 이거나, 변환에 실패한 경우 원본 바이너리를 그대로 반환합니다.
    func encodeToJPEGIfNeeded(_ imageData: Data, quality: Double) -> Data
}
