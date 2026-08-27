//
//  AbortFeedBatchRequestDTO.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//
import Foundation

// MARK: - 실패한 피드 배치의 R2 객체 정리 요청
nonisolated struct AbortFeedBatchRequestDTO: Encodable, Sendable {
    let action = "abortFeedBatch"
    let uploadSessionID: UUID
    let feedID: UUID
    let objectKeys: [String]
}
