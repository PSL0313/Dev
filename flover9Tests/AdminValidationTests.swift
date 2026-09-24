import XCTest
@testable import flover9

final class AdminValidationTests: XCTestCase {
    // MARK: - 관리자 화면은 운영 권한만 허용
    func testManagementRoles() {
        XCTAssertTrue(AdminUseCase.canManage(.admin))
        XCTAssertTrue(AdminUseCase.canManage(.manager))
        XCTAssertFalse(AdminUseCase.canManage(.user))
        XCTAssertFalse(AdminUseCase.canManage(.blogger))
        XCTAssertFalse(AdminUseCase.canManage(.homema))
    }

    // MARK: - 종료 시간과 시간대 검증
    func testScheduleValidation() throws {
        var draft = AdminScheduleDraft(eventID: UUID())
        draft.endAt = draft.startAt.addingTimeInterval(-1)
        XCTAssertThrowsError(try AdminUseCase.validateSchedule(draft))
        draft.endAt = nil
        draft.timeZone = "Invalid/Timezone"
        XCTAssertThrowsError(try AdminUseCase.validateSchedule(draft))
        draft.timeZone = "Asia/Seoul"
        XCTAssertNoThrow(try AdminUseCase.validateSchedule(draft))
    }

    func testOptionalFieldsAreExplicitlyCleared() throws {
        let dto = AdminScheduleWriteDTO(draft: AdminScheduleDraft(eventID: UUID()))
        let data = try JSONEncoder().encode(dto)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertTrue(json["end_at"] is NSNull)
        XCTAssertTrue(json["venue_name"] is NSNull)
        XCTAssertNil(json["title"])
    }

    func testIOSUploadRouting() throws {
        let dto = PresignFeedBatchRequestDTO(feedID: UUID(), feedURL: "https://example.com/feed", media: [])
        let data = try JSONEncoder().encode(dto)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(json["storageLayout"] as? String, "ios")
        XCTAssertEqual(json["action"] as? String, "presignFeedBatch")
    }

    func testLinksRejectLocalAndExecutableSchemes() {
        XCTAssertNil(AdminUseCase.webURL("file:///tmp/image.jpg"))
        XCTAssertNil(AdminUseCase.webURL("javascript:alert(1)"))
        XCTAssertNotNil(AdminUseCase.webURL("https://example.com/tickets"))
    }

    func testFeedSourceURLIsOptional() throws {
        XCTAssertNil(try AdminUseCase.optionalFeedURL(""))
        XCTAssertNil(try AdminUseCase.optionalFeedURL("  \n "))
        XCTAssertEqual(try AdminUseCase.optionalFeedURL(" https://example.com/feed ")?.absoluteString, "https://example.com/feed")
        XCTAssertThrowsError(try AdminUseCase.optionalFeedURL("not a URL"))
        XCTAssertThrowsError(try AdminUseCase.optionalFeedURL("file:///tmp/a"))
        let dto = PresignFeedBatchRequestDTO(feedID: UUID(), feedURL: nil, media: [])
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(dto)) as? [String: Any])
        XCTAssertNil(json["feedURL"])
        XCTAssertEqual(json["storageLayout"] as? String, "ios")
    }

    func testFeedResponseWithoutSourceURL() throws {
        let json = """
        {"id":"11111111-1111-4111-8111-111111111111","capture_date":"2026-09-23T00:00:00Z","uploaded_at":"2026-09-23T00:00:00Z","source":"instagram","permalink":null,"display_type":"feed","content_count":1}
        """
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try decoder.decode(FeedResponseDTO.self, from: Data(json.utf8))
        XCTAssertNil(try response.toEntity().permalink)
    }

    func testEmptyFeedMetadataIsOmitted() {
        let draft = FeedUploadDraft(title: "제목", sourceName: "", description: " \n ", captureDate: .now, source: "blogger", permalink: nil, memberCodes: [], media: [])
        XCTAssertEqual(draft.title, "제목")
        XCTAssertNil(draft.sourceName)
        XCTAssertNil(draft.description)
    }
}
