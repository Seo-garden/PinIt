import XCTest
@testable import PinItCore

final class AuthValidatorTests: XCTestCase {
    func testEmailValidationReturnsTrueForValidEmail() {
        XCTAssertTrue(AuthValidator.isValidEmail("pinit.user@example.com"))
    }

    func testEmailValidationReturnsFalseForInvalidEmail() {
        XCTAssertFalse(AuthValidator.isValidEmail("invalid-email"))
    }

    func testPasswordValidationReturnsTrueWhenValueExists() {
        XCTAssertTrue(AuthValidator.hasPasswordValue("secure-password"))
    }

    func testPasswordValidationReturnsFalseWhenEmpty() {
        XCTAssertFalse(AuthValidator.hasPasswordValue("   "))
    }
}
