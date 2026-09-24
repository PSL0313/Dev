//
//  AdminContent.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

import Foundation

// MARK: - 관리 목록의 구분
nonisolated enum AdminCategory: String, CaseIterable, Sendable {
    case feeds
    case schedules
    case events

    var title: String {
        switch self {
        case .feeds: return "피드 관리"
        case .schedules: return "일정 관리"
        case .events: return "행사 관리"
        }
    }
}

// MARK: - 목록에서 선택한 원본 Entity 보관
nonisolated enum AdminContent: Identifiable, Sendable {
    case feed(FeedEntity)
    case schedule(ScheduleEntity)
    case event(ScheduleEventEntity)

    var id: UUID {
        switch self {
        case .feed(let value): return value.id
        case .schedule(let value): return value.id
        case .event(let value): return value.id
        }
    }

    var title: String {
        switch self {
        case .feed(let value): return value.title ?? value.sourceName ?? "제목 없는 피드"
        case .schedule(let value): return value.title
        case .event(let value): return value.title
        }
    }
}

// MARK: - 관리자가 입력하는 피드 기본 정보
nonisolated struct AdminFeedDraft: Sendable {
    var id = UUID()                         // 생성 재시도에도 동일한 ID 사용
    var title = ""
    var description = ""
    var sourceName = ""
    var source = "blogger"
    var permalink = ""
    var captureDate = Date()
    var members: [MemberCode] = []
    var media: [UploadMediaFile] = []
    var mediaEdit = AdminMediaEdit()
}

// MARK: - 일정별로 달라지는 값만 편집
nonisolated struct AdminScheduleDraft: Sendable {
    var media: [UploadMediaFile] = []
    var mediaEdit = AdminMediaEdit()
    var id = UUID()
    var eventID: UUID
    var startAt = Date()
    var endAt: Date?
    var venueName = ""                       // 비워두면 공통 행사 장소 사용
    var status = ScheduleStatus.scheduled
    var isAllDay = false
    var timeZone = "Asia/Seoul"
}

// MARK: - 여러 일정이 공유하는 행사 정보
nonisolated struct AdminEventDraft: Sendable {
    var media: [UploadMediaFile] = []
    var mediaEdit = AdminMediaEdit()
    var id = UUID()
    var title = ""
    var type = ScheduleType.event
    var venueName = ""
    var description = ""
    var reservationURL = ""
    var thumbnailURL = ""
}

// MARK: - 서버 원본과 삭제 예약을 분리해 취소 시 서버를 변경하지 않음
nonisolated struct AdminMediaEdit: Sendable {
    var displayRole = "hero"               // 새 행사·일정 이미지의 배치 용도
    var existing: [AdminMediaItem] = []
    var removedIDs: Set<UUID> = []
}

nonisolated struct AdminMediaItem: Sendable {
    let id: UUID
    let url: URL
    let contentType: FeedMediaType
    let sortOrder: Int
}
