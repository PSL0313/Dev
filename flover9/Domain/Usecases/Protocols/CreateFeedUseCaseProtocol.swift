//
//  CreateFeedUseCaseProtocol.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//
// MARK: - 피드와 모든 첨부 미디어를 원자적으로 생성하는 기능 규약
protocol CreateFeedUseCaseProtocol: Sendable {
    func execute(draft: FeedUploadDraft) async throws -> FeedUploadResultEntity
}
