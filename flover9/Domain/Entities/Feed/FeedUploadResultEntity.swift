import Foundation

// MARK: - 피드와 모든 미디어가 확정된 뒤 반환하는 결과
nonisolated struct FeedUploadResultEntity: Sendable, Equatable {
    let feed: FeedEntity
    let mediaCount: Int
}
