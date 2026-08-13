import Foundation

// MARK: - 일정 첨부 콘텐츠의 상위 미디어 종류
nonisolated enum ScheduleMediaType: String, Sendable, Equatable, Codable {
    case image                         // 정지 이미지
    case video                         // MP4 또는 HLS 영상
}
