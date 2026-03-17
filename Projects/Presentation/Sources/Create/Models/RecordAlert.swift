//
//  RecordAlert.swift
//  Presentation
//

import Foundation

public enum RecordAlertText {
    public static let photoLimitTitle = NSLocalizedString("record.alert.photoLimit.title", value: "최대 5장까지 첨부 가능합니다", comment: "")
    public static let photoLimitMessage = NSLocalizedString("record.alert.photoLimit.message", value: "추가하려면 기존 사진을 삭제해주세요.", comment: "")
}

public enum RecordAlert {
    case photoLimitReached
    
    public var message: AlertMessage {
        switch self {
        case .photoLimitReached:
            return AlertMessage(title: RecordAlertText.photoLimitTitle, message: RecordAlertText.photoLimitMessage)
        }
    }
}
