import Foundation

// MARK: - 관리자 기능의 서버 접근 규약
@MainActor
protocol AdminRemoteDataSourceProtocol {
    func hasPendingSave(id: UUID) -> Bool
    func endEditing(id: UUID)
    func fetchProfile() async throws -> ReadUserProfileDTO
    func fetchMedia(category: AdminCategory, id: UUID) async throws -> [AdminMediaDTO]
    func fetchFeeds(offset: Int, query: String) async throws -> [FeedResponseDTO]
    func fetchSchedules(offset: Int, query: String) async throws -> [ScheduleDTO]
    func fetchEvents(offset: Int, query: String) async throws -> [ScheduleEventDTO]
    func updateFeed(_ draft: AdminFeedDraft) async throws
    func saveSchedule(_ draft: AdminScheduleDraft, isNew: Bool) async throws
    func saveEvent(_ draft: AdminEventDraft, isNew: Bool) async throws
    func delete(_ item: AdminContent) async throws -> AdminDeleteResponseDTO
}
