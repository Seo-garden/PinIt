import Foundation

public enum RecordPhotoReference: Equatable, Sendable {
    case url(URL)
    case data(Data)
}

public struct RecordLocation: Equatable, Sendable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct Record: Equatable, Sendable {
    public let id: UUID
    public let photo: RecordPhotoReference
    public private(set) var caption: String
    public let location: RecordLocation
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        photo: RecordPhotoReference,
        caption: String,
        location: RecordLocation,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.photo = photo
        self.caption = caption
        self.location = location
        self.createdAt = createdAt
    }

    public mutating func updateCaption(_ newCaption: String) {
        caption = newCaption
    }
}
