import Foundation

@MainActor
protocol AdminUseCaseProtocol {
    func endEditing(id: UUID)
    func authorize() async throws -> UserProfile
    func fetchMedia(category: AdminCategory, id: UUID) async throws -> [AdminMediaItem]
    func fetchItems(category: AdminCategory, offset: Int, query: String) async throws -> [AdminContent]
    func saveFeed(_ draft: AdminFeedDraft, isNew: Bool) async throws
    func saveSchedule(_ draft: AdminScheduleDraft, isNew: Bool) async throws
    func saveEvent(_ draft: AdminEventDraft, isNew: Bool) async throws
    func delete(_ item: AdminContent) async throws -> Bool
}
