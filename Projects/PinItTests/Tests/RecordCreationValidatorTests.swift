import XCTest
@testable import PinItCore

final class RecordCreationValidatorTests: XCTestCase {
    func testRecordCreationValidationReturnsTrueWhenAllRequiredValuesExist() {
        let result = RecordCreationValidator.hasRequiredValues(
            photo: .url(URL(string: "https://example.com/photo.jpg")!),
            caption: "광화문에서의 기록",
            latitude: 37.5759,
            longitude: 126.9768
        )

        XCTAssertTrue(result)
    }

    func testRecordCreationValidationReturnsFalseWhenPhotoIsMissing() {
        let result = RecordCreationValidator.hasRequiredValues(
            photo: nil,
            caption: "광화문에서의 기록",
            latitude: 37.5759,
            longitude: 126.9768
        )

        XCTAssertFalse(result)
    }

    func testRecordCreationValidationReturnsFalseWhenCaptionIsMissing() {
        let result = RecordCreationValidator.hasRequiredValues(
            photo: .url(URL(string: "https://example.com/photo.jpg")!),
            caption: "   ",
            latitude: 37.5759,
            longitude: 126.9768
        )

        XCTAssertFalse(result)
    }

    func testRecordCreationValidationReturnsFalseWhenLocationIsMissing() {
        let result = RecordCreationValidator.hasRequiredValues(
            photo: .url(URL(string: "https://example.com/photo.jpg")!),
            caption: "광화문에서의 기록",
            latitude: nil,
            longitude: 126.9768
        )

        XCTAssertFalse(result)
    }
}
