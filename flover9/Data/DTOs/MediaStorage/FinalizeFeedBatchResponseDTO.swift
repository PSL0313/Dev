//
//  FinalizeFeedBatchResponseDTO.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//


// MARK: - 피드 배치 확정 응답
nonisolated struct FinalizeFeedBatchResponseDTO: Decodable, Sendable {
    let feed: FeedResponseDTO
    let mediaCount: Int
}
