import Foundation

// MARK: - 관리자 DTO 변환, Domain 오류 분류 및 캐시 무효화
@MainActor
final class AdminRepository: AdminRepositoryProtocol {
    func endEditing(id: UUID) { dataSource.endEditing(id: id) }
    private let dataSource: AdminRemoteDataSourceProtocol
    private let feedCache: FeedCacheProtocol
    private let scheduleRepository: ScheduleRepositoryProtocol

    init(
        dataSource: AdminRemoteDataSourceProtocol,
        feedCache: FeedCacheProtocol,
        scheduleRepository: ScheduleRepositoryProtocol
    ) {
        self.dataSource = dataSource
        self.feedCache = feedCache
        self.scheduleRepository = scheduleRepository
    }

    func fetchProfile() async throws -> UserProfile {
        do {
            return try await dataSource.fetchProfile().toEntity()
        } catch {
            throw map(error)
        }
    }

    func fetchMedia(category: AdminCategory, id: UUID) async throws -> [AdminMediaItem] {
        do {
            return try await dataSource.fetchMedia(category: category, id: id).map { try $0.toEntity() }
        } catch {
            throw map(error)
        }
    }

    func fetchItems(category: AdminCategory, offset: Int, query: String) async throws -> [AdminContent] {
        do {
            switch category {
            case .feeds:
                return try await dataSource.fetchFeeds(offset: offset, query: query).map {
                    .feed(try $0.toEntity())
                }
            case .schedules:
                return try await dataSource.fetchSchedules(offset: offset, query: query).map {
                    .schedule($0.toEntity())
                }
            case .events:
                return try await dataSource.fetchEvents(offset: offset, query: query).map {
                    .event($0.toEntity())
                }
            }
        } catch {
            throw map(error)
        }
    }

    func updateFeed(_ draft: AdminFeedDraft) async throws {
        do {
            try await dataSource.updateFeed(draft)
            await invalidateCaches()
        } catch {
            if dataSource.hasPendingSave(id: draft.id) { throw AdminError.saveUnconfirmed }
            throw map(error)
        }
    }

    func saveSchedule(_ draft: AdminScheduleDraft, isNew: Bool) async throws {
        do {
            try await dataSource.saveSchedule(draft, isNew: isNew)
            await invalidateCaches()
        } catch {
            if dataSource.hasPendingSave(id: draft.id) { throw AdminError.saveUnconfirmed }
            throw map(error)
        }
    }

    func saveEvent(_ draft: AdminEventDraft, isNew: Bool) async throws {
        do {
            try await dataSource.saveEvent(draft, isNew: isNew)
            await invalidateCaches()
        } catch {
            if dataSource.hasPendingSave(id: draft.id) { throw AdminError.saveUnconfirmed }
            throw map(error)
        }
    }

    func delete(_ item: AdminContent) async throws -> Bool {
        do {
            let response = try await dataSource.delete(item)
            guard response.deleted else { throw AdminError.serverUnavailable }
            await invalidateCaches()
            return response.cleanupQueued
        } catch {
            throw map(error)
        }
    }

    func invalidateCaches() async {
        await feedCache.resetAll()
        // 진행 중이던 조회 결과도 무효화하도록 Repository를 통해 초기화합니다.
        await scheduleRepository.resetAll()
    }

    private func map(_ error: Error) -> AdminError {
        if let error = error as? AdminError { return error }
        guard let error = error as? SupabaseDataError else { return .serverUnavailable }
        switch error {
        case .unauthorized: return .permissionDenied
        case .network: return .networkUnavailable
        case .notFound: return .notFound
        case .database, .decoding, .unknown: return .serverUnavailable
        }
    }
}
