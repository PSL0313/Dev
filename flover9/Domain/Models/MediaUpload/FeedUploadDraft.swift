//
//  FeedUploadDraft.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

import Foundation

// MARK: - Presentation 계층이 작성한 피드 업로드 입력값
nonisolated struct FeedUploadDraft: Sendable, Equatable {
    let id: UUID
    let title: String?
    let sourceName: String?
    let description: String?
    let captureDate: Date
    let source: String
    let permalink: URL?                    // 앱에서 직접 작성한 피드는 원본 주소가 없을 수 있다.
    let memberCodes: [MemberCode]
    let media: [UploadMediaFile]

    init(
        id: UUID = UUID(),
        title: String?,
        sourceName: String?,
        description: String?,
        captureDate: Date,
        source: String,
        permalink: URL?,
        memberCodes: [MemberCode],
        media: [UploadMediaFile]
    ) {
        self.id = id
        self.title = Self.optionalText(title)
        self.sourceName = Self.optionalText(sourceName)
        self.description = Self.optionalText(description)
        self.captureDate = captureDate
        self.source = source
        self.permalink = permalink
        self.memberCodes = memberCodes
        self.media = media
    }

    // 비워 둔 선택 입력은 빈 문자열 대신 nil로 전달한다.
    private static func optionalText(_ value: String?) -> String? {
        guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return value
    }
}
