import Foundation

nonisolated struct AdminPresignRequestDTO: Encodable {
    let action: String
    let storageLayout = "ios"
    let feedID: UUID?
    let scheduleID: UUID?
    let eventID: UUID?
    let contentType: String
    let mimeType: String
    let mediaType: String
    let fileSizeBytes: Int64
    let sortOrder: Int
}

nonisolated struct AdminSignedUploadDTO: Decodable {
    let uploadSessionID: UUID
    let uploadURL: URL
    let requiredHeaders: [String: String]
}

// MARK: - 하나의 저장 요청으로 정보 수정, 추가 미디어 확정, 삭제 예약 반영
nonisolated struct AdminMediaSaveDTO<Draft: Encodable>: Encodable {
    let action = "saveAdminContent"
    let requestID: UUID
    let targetID: UUID
    let targetType: String
    let isNew: Bool
    let draft: Draft
    let expectedIDs: [UUID]
    let deletedIDs: [UUID]
    let sessionIDs: [UUID]
    let displayRole: String
}

nonisolated struct AdminMediaSavedDTO: Decodable {
    let saved: Bool
}
