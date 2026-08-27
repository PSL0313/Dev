import Foundation

// MARK: - Presentation 계층이 작성한 피드 업로드 입력값
nonisolated struct FeedUploadDraft: Sendable, Equatable {
    let id: UUID
    let title: String?
    let sourceName: String?
    let description: String?
    let captureDate: Date
    let source: String
    let permalink: URL
    let memberCodes: [MemberCode]
    let media: [UploadMediaFile]

    init(
        id: UUID = UUID(),
        title: String?,
        sourceName: String?,
        description: String?,
        captureDate: Date,
        source: String,
        permalink: URL,
        memberCodes: [MemberCode],
        media: [UploadMediaFile]
    ) {
        self.id = id
        self.title = title
        self.sourceName = sourceName
        self.description = description
        self.captureDate = captureDate
        self.source = source
        self.permalink = permalink
        self.memberCodes = memberCodes
        self.media = media
    }
}
