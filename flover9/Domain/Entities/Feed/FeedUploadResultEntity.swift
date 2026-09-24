//
//  FeedUploadResultEntity.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

import Foundation

// MARK: - 피드와 모든 미디어가 확정된 뒤 반환하는 결과
nonisolated struct FeedUploadResultEntity: Sendable, Equatable {
    let feed: FeedEntity
    let mediaCount: Int
}
