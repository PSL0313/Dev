//
//  ScheduleMediaDTO.swift
//  flover9
//
//  Created by 박선린 on 9/10/26.
//
import Foundation

// MARK: - Supabase schedule_media 테이블의 일정 미디어 응답 DTO
nonisolated struct ScheduleMediaDTO: Decodable, Sendable {
    let id: UUID                       // schedule_media.id
    let scheduleID: UUID?              // 개별 일정 미디어의 소유자
    var eventID: UUID? = nil           // 공통 행사 미디어의 소유자
    let mediaURL: URL                  // schedule_media.media_url
    let mediaType: ScheduleMediaType   // schedule_media.media_type
    let displayRole: ScheduleMediaDisplayRole // schedule_media.display_role
    let mimeType: ScheduleMIMEType     // schedule_media.mime_type
    let thumbnailURL: URL?             // schedule_media.thumbnail_url
    let sortOrder: Int                 // schedule_media.sort_order
    let width: Int?                    // schedule_media.width
    let height: Int?                   // schedule_media.height
    let durationSeconds: Double?       // schedule_media.duration_seconds
    let createdAt: Date                // schedule_media.created_at

    enum CodingKeys: String, CodingKey {
        case id, width, height
        case scheduleID = "schedule_id"
        case eventID = "event_id"
        case mediaURL = "media_url"
        case mediaType = "media_type"
        case displayRole = "display_role"
        case mimeType = "mime_type"
        case thumbnailURL = "thumbnail_url"
        case sortOrder = "sort_order"
        case durationSeconds = "duration_seconds"
        case createdAt = "created_at"
    }

    // MARK: - 일정 미디어 응답 DTO를 Domain Entity로 변환
    func toEntity() -> ScheduleMediaEntity {
        ScheduleMediaEntity(
            id: id,
            scheduleID: scheduleID,
            mediaURL: mediaURL,
            mediaType: mediaType,
            displayRole: displayRole,
            mimeType: mimeType,
            thumbnailURL: thumbnailURL,
            sortOrder: sortOrder,
            width: width,
            height: height,
            durationSeconds: durationSeconds,
            createdAt: createdAt,
            eventID: eventID
        )
    }
}
