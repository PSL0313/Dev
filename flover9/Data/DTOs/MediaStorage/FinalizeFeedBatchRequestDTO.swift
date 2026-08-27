//
//  FinalizeFeedBatchRequestDTO.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//
import Foundation

// MARK: - 피드와 업로드된 전체 미디어 확정 요청
nonisolated struct FinalizeFeedBatchRequestDTO: Encodable, Sendable {
    let action = "finalizeFeedBatch"
    let uploadSessionID: UUID
    let feedID: UUID
    let title: String?
    let sourceName: String?
    let description: String?
    let captureDate: String
    let source: String
    let permalink: String
    let memberCodes: [String]
    let media: [FinalizeFeedMediaItemDTO]
}
