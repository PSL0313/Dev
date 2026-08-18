import Foundation

// MARK: - Supabase schedule_details 테이블의 일정 상세 응답 DTO
nonisolated struct ScheduleDetailDTO: Decodable, Sendable {
    let scheduleID: UUID               // schedule_details.schedule_id
    let description: String?           // schedule_details.description
    let address: String?               // schedule_details.address
    let roadAddress: String?           // schedule_details.road_address
    let latitude: Double?              // schedule_details.latitude
    let longitude: Double?             // schedule_details.longitude
    let notice: String?                // schedule_details.notice
    let reservationURL: URL?           // schedule_details.reservation_url
    let externalURL: URL?              // schedule_details.external_url
    let createdAt: Date                // schedule_details.created_at
    let updatedAt: Date                // schedule_details.updated_at

    enum CodingKeys: String, CodingKey {
        case description, address, latitude, longitude, notice
        case scheduleID = "schedule_id"
        case roadAddress = "road_address"
        case reservationURL = "reservation_url"
        case externalURL = "external_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // MARK: - 일정 상세 응답 DTO를 Domain Entity로 변환
    func toEntity() -> ScheduleDetailEntity {
        ScheduleDetailEntity(
            scheduleID: scheduleID,
            description: description,
            address: address,
            roadAddress: roadAddress,
            latitude: latitude,
            longitude: longitude,
            notice: notice,
            reservationURL: reservationURL,
            externalURL: externalURL,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
