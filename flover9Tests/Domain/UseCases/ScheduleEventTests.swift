//
//  ScheduleEventTests.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

import Foundation
import Testing
@testable import flover9

@Suite("Schedule event separation")
@MainActor
struct ScheduleEventTests {
    private let scheduleID = UUID(uuidString: "11111111-1111-4111-8111-111111111111")!
    private let eventID = UUID(uuidString: "22222222-2222-4222-8222-222222222222")!

    private func fixture(linked: Bool = true, venue: String? = nil, placeID: String? = nil) throws -> ScheduleDTO {
        let timestamp = "2026-09-10T10:30:00Z"
        var data: [String: Any] = [
            "id": scheduleID.uuidString,
            "status": "scheduled", "start_at": timestamp, "is_all_day": false,
            "timezone": "Asia/Seoul", "created_at": timestamp, "updated_at": timestamp
        ]
        if let venue { data["venue_name"] = venue }
        if linked {
            data["event_id"] = eventID.uuidString
            data["schedule_events"] = [
                "id": eventID.uuidString, "title": "Shared musical", "schedule_type": "musical",
                "venue_name": "Shared venue", "description": "Shared description",
                "address": "Shared address", "road_address": "Shared road",
                "latitude": 37.5, "longitude": 127.0,
                "reservation_url": "https://example.com/tickets",
                "created_at": timestamp, "updated_at": timestamp
            ] as [String: Any]
        }
        if let placeID, var event = data["schedule_events"] as? [String: Any] {
            event["apple_place_id"] = placeID
            data["schedule_events"] = event
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(ScheduleDTO.self, from: JSONSerialization.data(withJSONObject: data))
    }

    @Test("행사 제목과 장소를 사용하되 일정 ID는 유지한다")
    func sharedSummary() throws {
        let entity = try fixture().toEntity()
        #expect(entity.id == scheduleID)
        #expect(entity.event.id == eventID)
        #expect(entity.title == "Shared musical")
        #expect(entity.venueName == "Shared venue")
    }

    @Test("행사 연결이 없는 잘못된 응답은 디코딩 단계에서 거부한다")
    func missingEventIsRejected() {
        #expect(throws: DecodingError.self) {
            try fixture(linked: false)
        }
    }

    @Test("개별 상세 행이 없어도 행사 상세 정보를 표시한다")
    func inheritedDetails() throws {
        let content = ScheduleDetailContent(schedule: try fixture().toEntity(), detail: nil, media: [])
            .resolvingEventDefaults()
        #expect(content.detail?.description == "Shared description")
        #expect(content.detail?.reservationURL?.host == "example.com")
        #expect(content.detail?.scheduleID == scheduleID)
    }

    @Test("다른 장소에는 공통 장소의 주소와 좌표를 섞지 않는다")
    func locationOverride() throws {
        let content = ScheduleDetailContent(schedule: try fixture(venue: "Other venue").toEntity(), detail: nil, media: [])
            .resolvingEventDefaults()
        #expect(content.schedule.venueName == "Other venue")
        #expect(content.detail?.address == nil)
        #expect(content.detail?.latitude == nil)
        #expect(content.detail?.description == "Shared description")
    }

    @Test("일정별 안내와 예약 URL이 공통값보다 우선한다")
    func detailOverride() throws {
        let schedule = try fixture().toEntity()
        let detail = ScheduleDetailEntity(scheduleID: scheduleID, description: "Special",
            address: nil, roadAddress: nil, latitude: nil, longitude: nil, notice: "Notice",
            reservationURL: URL(string: "https://example.org/special"), externalURL: nil,
            createdAt: schedule.createdAt, updatedAt: schedule.updatedAt)
        let result = ScheduleDetailContent(schedule: schedule, detail: detail, media: []).resolvingEventDefaults()
        #expect(result.detail?.description == "Special")
        #expect(result.detail?.reservationURL?.host == "example.org")
        #expect(result.detail?.address == "Shared address")
    }

    @Test("공통 미디어의 일정 ID는 nil, 행사 ID는 보존된다")
    func sharedMediaDecoding() throws {
        let data: [String: Any] = [
            "id": UUID().uuidString, "event_id": eventID.uuidString,
            "media_url": "https://example.com/poster.jpg",
            "media_type": "image", "mime_type": "image/jpeg", "sort_order": 0,
            "display_role": "hero",
            "created_at": "2026-09-10T00:00:00Z"
        ]
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let dto = try decoder.decode(ScheduleMediaDTO.self, from: JSONSerialization.data(withJSONObject: data))
        #expect(dto.toEntity().scheduleID == nil)
        #expect(dto.toEntity().eventID == eventID)
        #expect(dto.toEntity().displayRole == .hero)
    }

    @Test("UseCase가 공통 정보를 조합한다")
    func useCase() async throws {
        let raw = ScheduleDetailContent(schedule: try fixture().toEntity(), detail: nil, media: [])
        let useCase = FetchScheduleDetailUseCase(scheduleRepository: FixtureRepository(content: raw))
        let result = try await useCase.execute(scheduleID: scheduleID)
        #expect(result.detail?.description == "Shared description")
    }

    @Test("장소 ID는 행사에서 디코딩되어 상세 정보로 상속된다")
    func inheritedApplePlaceID() throws {
        let schedule = try fixture(placeID: "shared-place").toEntity()
        #expect(schedule.event.applePlaceID == "shared-place")
        let result = ScheduleDetailContent(schedule: schedule, detail: nil, media: []).resolvingEventDefaults()
        #expect(result.detail?.applePlaceID == "shared-place")
        #expect(result.detail?.address == "Shared address")
    }

    @Test("상세 장소 ID는 누락, null, 문자열을 디코딩한다", arguments: [0, 1, 2])
    func detailApplePlaceIDDecoding(mode: Int) throws {
        var data: [String: Any] = [
            "schedule_id": scheduleID.uuidString,
            "created_at": "2026-09-10T00:00:00Z",
            "updated_at": "2026-09-10T00:00:00Z"
        ]
        if mode == 1 { data["apple_place_id"] = NSNull() }
        if mode == 2 { data["apple_place_id"] = "override-place" }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let dto = try decoder.decode(ScheduleDetailDTO.self, from: JSONSerialization.data(withJSONObject: data))
        #expect(dto.toEntity().applePlaceID == (mode == 2 ? "override-place" : nil))
    }

    @Test("장소 ID만 달라도 공통 주소와 좌표를 상속하지 않는다")
    func applePlaceIDOverride() throws {
        let schedule = try fixture(placeID: "shared-place").toEntity()
        let detail = ScheduleDetailEntity(scheduleID: scheduleID, description: nil,
            address: nil, roadAddress: nil, latitude: nil, longitude: nil, notice: nil,
            reservationURL: nil, externalURL: nil, createdAt: schedule.createdAt,
            updatedAt: schedule.updatedAt, applePlaceID: "override-place")
        let result = ScheduleDetailContent(schedule: schedule, detail: detail, media: []).resolvingEventDefaults()
        #expect(result.detail?.applePlaceID == "override-place")
        #expect(result.detail?.address == nil)
        #expect(result.detail?.latitude == nil)
        #expect(result.detail?.description == "Shared description")
    }

    @Test("장소명이 바뀌면 공통 장소 ID를 상속하지 않는다")
    func changedVenueClearsApplePlaceID() throws {
        let schedule = try fixture(venue: "Other venue", placeID: "shared-place").toEntity()
        let result = ScheduleDetailContent(schedule: schedule, detail: nil, media: []).resolvingEventDefaults()
        #expect(result.detail?.applePlaceID == nil)
    }

    private struct FixtureRepository: ScheduleRepositoryProtocol {
        let content: ScheduleDetailContent
        func fetchScheduleCovers() async throws -> [ScheduleEntity] { [content.schedule] }
        func fetchScheduleDetail(scheduleID: UUID) async throws -> ScheduleDetailContent { content }
        func resetCovers() async {}
        func reset(scheduleID: UUID) async {}
        func resetAll() async {}
    }
}
