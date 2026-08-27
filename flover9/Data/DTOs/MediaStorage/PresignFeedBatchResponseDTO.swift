//
//  PresignFeedBatchResponseDTO.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//
import Foundation

// MARK: - 피드 배치 업로드 URL 발급 응답
nonisolated struct PresignFeedBatchResponseDTO: Decodable, Sendable {
    let uploadSessionID: UUID
    let feedID: UUID
    let uploads: [PresignedMediaUploadDTO]
}
