import Foundation

public protocol RecordRepositoryProtocol {
    func create(_ record: Record) async throws -> Record
    func readAll() async throws -> [Record]
    func delete(recordId: UUID) async throws
    func updateCaption(recordId: UUID, caption: String) async throws -> Record
}
