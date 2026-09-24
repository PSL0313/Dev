//
//  AdminRepositoryProtocol.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

import Foundation

@MainActor
protocol AdminRepositoryProtocol {
    func endEditing(id: UUID)
    func fetchProfile() async throws -> UserProfile
    func fetchMedia(category: AdminCategory, id: UUID) async throws -> [AdminMediaItem]
    func fetchItems(category: AdminCategory, offset: Int, query: String) async throws -> [AdminContent]
    func updateFeed(_ draft: AdminFeedDraft) async throws
    func saveSchedule(_ draft: AdminScheduleDraft, isNew: Bool) async throws
    func saveEvent(_ draft: AdminEventDraft, isNew: Bool) async throws
    func delete(_ item: AdminContent) async throws -> Bool
    func invalidateCaches() async
}
