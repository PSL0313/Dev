//
//  AbortFeedBatchResponseDTO.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//


// MARK: - 업로드 취소 응답
nonisolated struct AbortFeedBatchResponseDTO: Decodable, Sendable {
    let aborted: Bool
    let cleanupPending: Bool
}
