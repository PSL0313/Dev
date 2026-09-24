//
//  AdminMutationDTO.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

import Foundation

// MARK: - 수정할 칼럼만 전송해 소유자와 미디어 정보를 보존
nonisolated struct AdminFeedUpdateDTO: Encodable {
    let title: String
    let description: String
    let source_name: String
    let capture_date: String

    init(_ draft: AdminFeedDraft) {
        title = draft.title
        description = draft.description
        source_name = draft.sourceName
        capture_date = draft.captureDate.ISO8601Format()
    }
}

// MARK: - Optional 칼럼을 비우면 JSON null로 전송
nonisolated struct AdminScheduleWriteDTO: Encodable {
    let draft: AdminScheduleDraft

    enum CodingKeys: String, CodingKey {
        case id, status, timezone
        case eventID = "event_id"
        case startAt = "start_at"
        case endAt = "end_at"
        case venueName = "venue_name"
        case isAllDay = "is_all_day"
    }

    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(draft.id, forKey: .id)
        try values.encode(draft.eventID, forKey: .eventID)
        try values.encode(draft.startAt.ISO8601Format(), forKey: .startAt)
        try values.encode(draft.endAt?.ISO8601Format(), forKey: .endAt)
        try values.encode(draft.venueName.isEmpty ? nil : draft.venueName, forKey: .venueName)
        try values.encode(draft.status.rawValue, forKey: .status)
        try values.encode(draft.isAllDay, forKey: .isAllDay)
        try values.encode(draft.timeZone, forKey: .timezone)
    }
}

// MARK: - 행사 수정 시 주소·좌표·공지 등 편집하지 않은 값은 유지
nonisolated struct AdminEventWriteDTO: Encodable {
    let draft: AdminEventDraft

    enum CodingKeys: String, CodingKey {
        case id, title, description
        case type = "schedule_type"
        case venueName = "venue_name"
        case reservationURL = "reservation_url"
        case thumbnailURL = "thumbnail_url"
    }

    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(draft.id, forKey: .id)
        try values.encode(draft.title, forKey: .title)
        try values.encode(draft.type.rawValue, forKey: .type)
        try values.encode(draft.venueName.isEmpty ? nil : draft.venueName, forKey: .venueName)
        try values.encode(draft.description.isEmpty ? nil : draft.description, forKey: .description)
        try values.encode(draft.reservationURL.isEmpty ? nil : draft.reservationURL, forKey: .reservationURL)
        try values.encode(draft.thumbnailURL.isEmpty ? nil : draft.thumbnailURL, forKey: .thumbnailURL)
    }
}

nonisolated struct AdminDeleteRequestDTO: Encodable {
    let action: String
    let parentID: UUID
}

nonisolated struct AdminDeleteResponseDTO: Decodable {
    let deleted: Bool
    let cleanupQueued: Bool
    let cleanupCount: Int
}

nonisolated struct AdminSavedIDDTO: Decodable {
    let id: UUID
}
