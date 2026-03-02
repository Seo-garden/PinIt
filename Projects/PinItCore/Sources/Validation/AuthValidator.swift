import Foundation

public enum AuthValidator {
    public static func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    public static func hasPasswordValue(_ password: String) -> Bool {
        !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
