//
//  AppMode.swift
//  Presentation
//
//  Created by 김민우 on 3/13/26.
//

import Foundation


// MARK: value
/// 앱이 어떤 실행 모드로 동작하는지를 나타내는 값입니다.
///
/// 주로 의존성 주입 시 실제 구현과 테스트용 Fake 구현을 구분하기 위한 기준으로 사용됩니다.
/// 예를 들어 release 모드에서는 실제 서비스 의존성을, debug 모드에서는 Fake 또는 Mock 성격의 의존성을 선택하도록 구성할 수 있습니다.
public enum AppMode: Sendable, Hashable, Codable {
    case release
    case debug
}
