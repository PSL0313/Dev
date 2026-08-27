//
//  MediaStorageRepositoryProtocol.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//
import Foundation

// MARK: - 피드 미디어 저장 기능을 Domain 계층에 제공하는 저장소 규약
protocol MediaStorageRepositoryProtocol: Sendable {
    func createFeed(_ draft: FeedUploadDraft) async throws -> FeedUploadResultEntity
    func deleteFeedMedia(mediaID: UUID) async throws
}
