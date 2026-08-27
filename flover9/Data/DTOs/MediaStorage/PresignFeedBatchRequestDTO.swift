//
//  PresignFeedBatchRequestDTO.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//
import Foundation

// MARK: - 피드 배치 업로드 URL 발급 요청
nonisolated struct PresignFeedBatchRequestDTO: Encodable, Sendable {
    let action = "presignFeedBatch"
    let feedID: UUID
    let media: [PresignMediaItemDTO]
}
