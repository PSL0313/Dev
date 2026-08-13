import Foundation

// MARK: - Supabase schedules 테이블의 일정 요약 응답 DTO
nonisolated struct ScheduleDTO: Decodable, Sendable {
    let id: UUID                       // schedules.id
    let title: String                  // schedules.title
    let venueName: String?             // schedules.venue_name
    let scheduleType: ScheduleType     // schedules.schedule_type
    let status: ScheduleStatus         // schedules.status
    let startAt: Date                  // schedules.start_at
    let endAt: Date?                   // schedules.end_at
    let isAllDay: Bool                 // schedules.is_all_day
    let operationStartTime: String?    // schedules.operation_start_time
    let operationEndTime: String?      // schedules.operation_end_time
    let timeZone: String               // schedules.timezone
    let thumbnailURL: URL?             // schedules.thumbnail_url
    let externalURL: URL?              // schedules.external_url
    let externalContentID: String?     // schedules.external_content_id
    let participants: [ScheduleParticipantDTO]? // schedule_members의 멤버 코드 목록
    let createdAt: Date                // schedules.created_at
    let updatedAt: Date                // schedules.updated_at

    enum CodingKeys: String, CodingKey {
        case id, title, status
        case venueName = "venue_name"
        case scheduleType = "schedule_type"
        case startAt = "start_at"
        case endAt = "end_at"
        case isAllDay = "is_all_day"
        case operationStartTime = "operation_start_time"
        case operationEndTime = "operation_end_time"
        case timeZone = "timezone"
        case thumbnailURL = "thumbnail_url"
        case externalURL = "external_url"
        case externalContentID = "external_content_id"
        case participants = "schedule_members"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // MARK: - 일정 응답 DTO를 Domain Entity로 변환
    func toEntity() -> ScheduleEntity {

        return ScheduleEntity(
            id: id,
            title: title,
            venueName: venueName,
            type: scheduleType,
            status: status,
            startAt: startAt,
            endAt: endAt,
            isAllDay: isAllDay,
            operationStartTime: operationStartTime,
            operationEndTime: operationEndTime,
            timeZone: timeZone,
            thumbnailURL: thumbnailURL,
            externalURL: externalURL,
            externalContentID: externalContentID,
            participantMemberCodes: participants?.isEmpty == false ? participants?.map{ $0.memberCode } : nil,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
