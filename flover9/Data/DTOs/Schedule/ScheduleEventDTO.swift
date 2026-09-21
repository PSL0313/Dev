//
//  ScheduleEventDTO.swift
//  flover9
//
//  Created by 박선린 on 9/10/26.
//
import Foundation

// schedule_events 응답. 행사 공통 정보와 일정별 정보를 구분해 디코딩합니다.
nonisolated struct ScheduleEventDTO: Decodable, Sendable {
    let id: UUID
    let title: String
    let scheduleType: ScheduleType
    let venueName: String?
    let thumbnailURL: URL?
    let description: String?
    let address: String?
    let roadAddress: String?
    let applePlaceID: String?
    let latitude: Double?
    let longitude: Double?
    let notice: String?
    let reservationURL: URL?
    let externalURL: URL?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, description, address, latitude, longitude, notice
        case scheduleType = "schedule_type"
        case venueName = "venue_name"
        case thumbnailURL = "thumbnail_url"
        case roadAddress = "road_address"
        case applePlaceID = "apple_place_id"
        case reservationURL = "reservation_url"
        case externalURL = "external_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    func toEntity() -> ScheduleEventEntity {
        ScheduleEventEntity(id: id, title: title, type: scheduleType,
            venueName: venueName, thumbnailURL: thumbnailURL, description: description,
            address: address, roadAddress: roadAddress, latitude: latitude, longitude: longitude,
            notice: notice, reservationURL: reservationURL, externalURL: externalURL,
            createdAt: createdAt, updatedAt: updatedAt, applePlaceID: applePlaceID)
    }
}
