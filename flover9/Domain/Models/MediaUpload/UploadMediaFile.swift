import Foundation

// MARK: - 화면에서 선택한 로컬 파일의 업로드 정보
nonisolated struct UploadMediaFile: Sendable, Equatable {
    let fileURL: URL
    let contentType: FeedMediaType
    let fileSizeBytes: Int64
    let sortOrder: Int
    let checksumSHA256: String?

    init(
        fileURL: URL,
        contentType: FeedMediaType,
        fileSizeBytes: Int64,
        sortOrder: Int,
        checksumSHA256: String? = nil
    ) {
        self.fileURL = fileURL
        self.contentType = contentType
        self.fileSizeBytes = fileSizeBytes
        self.sortOrder = sortOrder
        self.checksumSHA256 = checksumSHA256
    }
}
