//
//  ScheduleCacheTests.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

import Foundation
import Testing
@testable import flover9

@Suite("Schedule memory cache")
@MainActor
struct ScheduleCacheTests {
    @Test("미조회와 빈 목록을 구분하고 빈 목록도 재조회하지 않는다")
    func emptyCovers() async throws {
        let cache = ScheduleCache()
        #expect(await cache.covers() == nil)
        let source = try FixtureDataSource()
        source.covers = []
        let repository = ScheduleRepository(dataSource: source, cache: cache)
        #expect(try await repository.fetchScheduleCovers().isEmpty)
        #expect(try await repository.fetchScheduleCovers().isEmpty)
        #expect(source.coversCalls == 1)
        #expect(await cache.covers()?.isEmpty == true)
    }

    @Test("홈 요약을 상세 조회에서 재사용하고 없는 상세와 미디어도 캐싱한다")
    func reuseCoversAndEmptyDetail() async throws {
        let source = try FixtureDataSource()
        let repository = ScheduleRepository(dataSource: source, cache: ScheduleCache())
        let covers = try await repository.fetchScheduleCovers()
        let first = try await repository.fetchScheduleDetail(scheduleID: source.schedule.id)
        let second = try await repository.fetchScheduleDetail(scheduleID: source.schedule.id)
        #expect(covers.first?.id == second.schedule.id)
        #expect(first.detail == nil && second.detail == nil)
        #expect(second.media.isEmpty)
        #expect(source.scheduleCalls == 0)
        #expect(source.detailCalls == 1 && source.mediaCalls == 1)
        #expect(source.requestedEventID == source.schedule.eventID)
    }

    @Test("상세 화면 직접 진입도 캐싱하고 공통 행사 정보를 계속 조합한다")
    func directDetailUseCase() async throws {
        let source = try FixtureDataSource()
        let repository = ScheduleRepository(dataSource: source, cache: ScheduleCache())
        let useCase = FetchScheduleDetailUseCase(scheduleRepository: repository)
        _ = try await useCase.execute(scheduleID: source.schedule.id)
        let cached = try await useCase.execute(scheduleID: source.schedule.id)
        #expect(cached.detail?.description == "Shared description")
        #expect(source.scheduleCalls == 1)
        #expect(source.detailCalls == 1 && source.mediaCalls == 1)
    }

    @Test("일정별 상세 캐시는 서로 섞이지 않는다")
    func separateScheduleIDs() async throws {
        let cache = ScheduleCache()
        let first = try makeSchedule()
        let second = try makeSchedule()
        await cache.saveDetail(.init(schedule: first, detail: nil, media: []))
        await cache.saveDetail(.init(schedule: second, detail: nil, media: []))
        await cache.reset(first.id)
        #expect(await cache.detail(for: first.id) == nil)
        #expect(await cache.detail(for: second.id)?.schedule.id == second.id)
    }

    @Test("실패한 상세 조회는 캐싱하지 않아 재시도가 가능하다")
    func failedDetailCanRetry() async throws {
        let cache = ScheduleCache()
        let source = try FixtureDataSource()
        source.mediaError = .network
        let repository = ScheduleRepository(dataSource: source, cache: cache)
        await #expect(throws: ScheduleError.networkUnavailable) {
            try await repository.fetchScheduleDetail(scheduleID: source.schedule.id)
        }
        #expect(await cache.detail(for: source.schedule.id) == nil)
        source.mediaError = nil
        _ = try await repository.fetchScheduleDetail(scheduleID: source.schedule.id)
        #expect(source.mediaCalls == 2)
    }

    @Test("잘못 연결된 행사 데이터는 캐싱하지 않는다")
    func invalidEventCanRetry() async throws {
        let cache = ScheduleCache()
        let source = try FixtureDataSource()
        source.covers = [try makeSchedule(validEvent: false)]
        let repository = ScheduleRepository(dataSource: source, cache: cache)
        await #expect(throws: ScheduleError.invalidScheduleData) {
            try await repository.fetchScheduleCovers()
        }
        #expect(await cache.covers() == nil)
        source.covers = [source.schedule]
        #expect(try await repository.fetchScheduleCovers().count == 1)
        #expect(source.coversCalls == 2)
    }

    @Test("미디어는 원격과 캐시 모두 표시 순서와 ID 순으로 반환한다")
    func sortedMedia() async throws {
        let source = try FixtureDataSource()
        let lowID = UUID(uuidString: "11111111-1111-4111-8111-111111111111")!
        let highID = UUID(uuidString: "22222222-2222-4222-8222-222222222222")!
        let lastID = UUID(uuidString: "33333333-3333-4333-8333-333333333333")!
        source.media = [
            try makeMedia(id: lastID, order: 2, scheduleID: source.schedule.id),
            try makeMedia(id: highID, order: 0, scheduleID: source.schedule.id),
            try makeMedia(id: lowID, order: 0, scheduleID: source.schedule.id)
        ]
        let repository = ScheduleRepository(dataSource: source, cache: ScheduleCache())
        for _ in 0..<2 {
            let result = try await repository.fetchScheduleDetail(scheduleID: source.schedule.id)
            #expect(result.media.map(\.id) == [lowID, highID, lastID])
        }
        #expect(source.mediaCalls == 1)
    }

    @Test("목록 초기화는 상세를 유지하고 전체 초기화는 모든 데이터를 지운다")
    func coversAndAllReset() async throws {
        let source = try FixtureDataSource()
        let cache = ScheduleCache()
        let repository = ScheduleRepository(dataSource: source, cache: cache)
        let coversUseCase = FetchScheduleCoversUseCase(scheduleRepository: repository)
        _ = try await coversUseCase.execute()
        _ = try await repository.fetchScheduleDetail(scheduleID: source.schedule.id)
        await coversUseCase.reset()
        #expect(await cache.covers() == nil)
        #expect(await cache.detail(for: source.schedule.id) != nil)
        _ = try await coversUseCase.execute()
        #expect(source.coversCalls == 2)
        await coversUseCase.resetAll()
        #expect(await cache.covers() == nil)
        #expect(await cache.detail(for: source.schedule.id) == nil)
        #expect(await cache.schedule(for: source.schedule.id) == nil)
    }

    @Test("상세 UseCase 초기화 후에는 일정 요약부터 다시 조회한다")
    func detailReset() async throws {
        let source = try FixtureDataSource()
        let repository = ScheduleRepository(dataSource: source, cache: ScheduleCache())
        let useCase = FetchScheduleDetailUseCase(scheduleRepository: repository)
        _ = try await repository.fetchScheduleCovers()
        _ = try await useCase.execute(scheduleID: source.schedule.id)
        await useCase.reset(scheduleID: source.schedule.id)
        _ = try await useCase.execute(scheduleID: source.schedule.id)
        #expect(source.scheduleCalls == 1)
        #expect(source.detailCalls == 2 && source.mediaCalls == 2)
        _ = try await repository.fetchScheduleCovers()
        #expect(source.coversCalls == 2)
    }

    @Test("새 캐시 인스턴스에는 이전 인스턴스의 데이터가 없다")
    func instanceLifetime() async throws {
        let cache = ScheduleCache()
        await cache.saveCovers([try makeSchedule()])
        #expect(await ScheduleCache().covers() == nil)
    }

    @Test("초기화 전 시작된 원격 요청이 완료되어도 캐시를 되살리지 않는다")
    func resetDuringFetch() async throws {
        let source = try FixtureDataSource()
        let cache = ScheduleCache()
        let repository = ScheduleRepository(dataSource: source, cache: cache)
        source.beforeReturningCovers = { await repository.resetAll() }
        _ = try await repository.fetchScheduleCovers()
        #expect(await cache.covers() == nil)
        source.beforeReturningCovers = nil
        _ = try await repository.fetchScheduleCovers()
        #expect(source.coversCalls == 2)
        #expect(await cache.covers()?.count == 1)
    }
}

@MainActor
private final class FixtureDataSource: ScheduleRemoteDataSourceProtocol {
    let schedule: ScheduleDTO
    var covers: [ScheduleDTO]
    var media: [ScheduleMediaDTO] = []
    var mediaError: SupabaseDataError?
    var beforeReturningCovers: (() async -> Void)?
    private(set) var coversCalls = 0
    private(set) var scheduleCalls = 0
    private(set) var detailCalls = 0
    private(set) var mediaCalls = 0
    private(set) var requestedEventID: UUID?

    init() throws {
        schedule = try makeSchedule()
        covers = [schedule]
    }

    func fetchScheduleCovers() async throws -> [ScheduleDTO] {
        coversCalls += 1
        await beforeReturningCovers?()
        return covers
    }

    func fetchSchedule(id: UUID) async throws -> ScheduleDTO {
        scheduleCalls += 1
        return schedule
    }

    func fetchScheduleDetail(scheduleID: UUID) async throws -> ScheduleDetailDTO? {
        detailCalls += 1
        return nil
    }

    func fetchScheduleMedia(scheduleID: UUID, eventID: UUID?) async throws -> [ScheduleMediaDTO] {
        mediaCalls += 1
        requestedEventID = eventID
        if let mediaError { throw mediaError }
        return media
    }
}

private func makeSchedule(validEvent: Bool = true) throws -> ScheduleDTO {
    let eventID = UUID()
    return try decode([
        "id": UUID().uuidString, "event_id": eventID.uuidString,
        "status": "scheduled", "start_at": "2026-09-20T10:00:00Z",
        "is_all_day": false, "timezone": "Asia/Seoul",
        "created_at": "2026-09-10T00:00:00Z", "updated_at": "2026-09-10T00:00:00Z",
        "schedule_events": [
            "id": (validEvent ? eventID : UUID()).uuidString,
            "title": "Shared musical", "schedule_type": "musical",
            "description": "Shared description",
            "created_at": "2026-09-10T00:00:00Z", "updated_at": "2026-09-10T00:00:00Z"
        ]
    ])
}

private func makeMedia(id: UUID, order: Int, scheduleID: UUID) throws -> ScheduleMediaDTO {
    try decode([
        "id": id.uuidString, "schedule_id": scheduleID.uuidString,
        "media_url": "https://example.com/poster.jpg", "media_type": "image",
        "display_role": "hero", "mime_type": "image/jpeg", "sort_order": order,
        "created_at": "2026-09-10T00:00:00Z"
    ])
}

private func decode<T: Decodable>(_ json: [String: Any]) throws -> T {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(T.self, from: JSONSerialization.data(withJSONObject: json))
}
