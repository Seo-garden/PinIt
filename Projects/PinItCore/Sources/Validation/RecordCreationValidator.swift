import Foundation

public enum RecordCreationValidator {
    public static func hasRequiredValues(
        photo: RecordPhotoReference?,
        caption: String,
        latitude: Double?,
        longitude: Double?
    ) -> Bool {
        guard photo != nil else { return false }

        let trimmedCaption = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCaption.isEmpty else { return false }

        guard let latitude, let longitude else { return false }
        guard (-90.0...90.0).contains(latitude) else { return false }
        guard (-180.0...180.0).contains(longitude) else { return false }

        return true
    }
}
