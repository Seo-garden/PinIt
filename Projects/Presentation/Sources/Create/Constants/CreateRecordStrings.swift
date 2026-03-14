//
//  CreateRecordStrings.swift
//  Presentation
//
//  Created by 서정원 on 3/14/26.
//

import Foundation

enum CreateRecordStrings {
    static let newMemoryTitle = NSLocalizedString("record.title", value: "New Memory", comment: "")
    static let cameraDeniedTitle = NSLocalizedString("record.alert.cameraDenied.title", value: "카메라 접근이 거부되었습니다.", comment: "")
    static let cameraDeniedMessage = NSLocalizedString("record.alert.cameraDenied.message", value: "설정 > 개인정보 보호 > App > 카메라에서 허용해주세요.", comment: "")
    static let galleryDeniedTitle = NSLocalizedString("record.alert.galleryDenied.title", value: "사진 보관함 접근이 거부되었습니다.", comment: "")
    static let galleryDeniedMessage = NSLocalizedString("record.alert.galleryDenied.message", value: "설정 > 개인정보 보호 > App > 사진에서 허용해주세요.", comment: "")
    static let cameraUnavailableMessage = NSLocalizedString("record.alert.cameraUnavailable", value: "이 기기에서는 카메라를 사용할 수 없습니다.", comment: "")
    static let photoErrorMessage = NSLocalizedString("record.alert.photoError", value: "Photo Error", comment: "")
    static let saveSuccessTitle = NSLocalizedString("record.alert.saveSuccess.title", value: "Saved", comment: "")
    static let saveSuccessMessage = NSLocalizedString("record.alert.saveSuccess.message", value: "Memory has been recorded.", comment: "")
    static let cancel = NSLocalizedString("common.cancel", value: "취소", comment: "")
    static let openSettings = NSLocalizedString("common.openSettings", value: "설정 열기", comment: "")
}
