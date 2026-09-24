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
    let storageLayout = "ios"             // 수집앱과 구분해 feeds/{피드 ID} 경로를 사용
    let feedID: UUID
    let feedURL: String?                   // iOS는 원본 주소 없이 피드 ID로 업로드 경로를 구분
    let media: [PresignMediaItemDTO]
}
