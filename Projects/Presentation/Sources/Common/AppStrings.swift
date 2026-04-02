//
//  AppStrings.swift
//  Presentation
//
//  Created by 서정원 on 3/20/26.
//

import Foundation

enum AppStrings {
    enum Common {
        static let cancel = NSLocalizedString("common.cancel", value: "취소", comment: "")
        static let confirm = NSLocalizedString("common.confirm", value: "확인", comment: "")
        static let openSettings = NSLocalizedString("common.openSettings", value: "설정으로 이동", comment: "")
    }

    enum Record {
        static let newRecordTitle = NSLocalizedString("record.title", value: "오늘을 남기기", comment: "")
        static let cameraDeniedTitle = NSLocalizedString("record.alert.cameraDenied.title", value: "카메라 접근이 거부되었습니다.", comment: "")
        static let cameraDeniedMessage = NSLocalizedString("record.alert.cameraDenied.message", value: "해당 기능을 사용하려면 카메라에서 권한을 허용해주세요.", comment: "")
        static let galleryDeniedTitle = NSLocalizedString("record.alert.galleryDenied.title", value: "사진 보관함 접근이 거부되었습니다.", comment: "")
        static let galleryDeniedMessage = NSLocalizedString("record.alert.galleryDenied.message", value: "해당 기능을 사용하려면 사진 보관함에서 접근을 허용해주세요.", comment: "")
        static let cameraUnavailableMessage = NSLocalizedString("record.alert.cameraUnavailable", value: "이 기기에서는 카메라를 사용할 수 없습니다.", comment: "")
        static let photoErrorMessage = NSLocalizedString("record.alert.photoError", value: "사진 에러", comment: "")
    }

    enum Detail {
        static let title = NSLocalizedString("detail.title", value: "기록 상세", comment: "")
        static let deleteTitle = NSLocalizedString("detail.alert.delete.title", value: "기록 삭제", comment: "")
        static let deleteMessage = NSLocalizedString("detail.alert.delete.message", value: "이 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.", comment: "")
        static let delete = NSLocalizedString("detail.alert.delete.action", value: "삭제", comment: "")
        static let save = NSLocalizedString("detail.save", value: "저장", comment: "")
        static let saveFailTitle = NSLocalizedString("detail.alert.saveFail.title", value: "저장 실패", comment: "")
        static let saveFailMessage = NSLocalizedString("detail.alert.saveFail.message", value: "캡션 저장에 실패했습니다. 다시 시도해주세요.", comment: "")
        static let deleteFailTitle = NSLocalizedString("detail.alert.deleteFail.title", value: "삭제 실패", comment: "")
        static let deleteFailMessage = NSLocalizedString("detail.alert.deleteFail.message", value: "기록 삭제에 실패했습니다. 다시 시도해주세요.", comment: "")
        static let emptyCaptionTitle = NSLocalizedString("detail.alert.emptyCaption.title", value: "캡션 필요", comment: "")
        static let emptyCaptionMessage = NSLocalizedString("detail.alert.emptyCaption.message", value: "캡션을 비우고 저장할 수 없습니다!", comment: "")
    }

    enum Search {
        static let title = NSLocalizedString("search.title", value: "장소 검색", comment: "")
        static let errorTitle = NSLocalizedString("search.alert.error.title", value: "검색 오류", comment: "")
    }

    enum Map {
        static let locationDeniedTitle = NSLocalizedString("map.alert.locationDenied.title", value: "위치 권한이 필요합니다", comment: "")
        static let locationDeniedMessage = NSLocalizedString("map.alert.locationDenied.message", value: "해당 기능을 사용하려면 위치에서 접근을 허용해주세요.", comment: "")
    }
}
