//
//  DeleteFeedMediaRequestDTO.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//
import Foundation

// MARK: - 피드 미디어 삭제 요청
nonisolated struct DeleteFeedMediaRequestDTO: Encodable, Sendable {
    let action = "deleteFeedMedia"
    let mediaID: UUID
}
