import Foundation

// MARK: - 일정 첨부 파일에서 지원하는 실제 MIME 타입
nonisolated enum ScheduleMIMEType: String, Sendable, Equatable, Codable {
    case jpeg = "image/jpeg"                       // JPEG 이미지
    case png = "image/png"                         // PNG 이미지
    case webP = "image/webp"                       // WebP 이미지
    case avif = "image/avif"                       // AVIF 이미지
    case mp4 = "video/mp4"                         // MP4 영상
    case hls = "application/vnd.apple.mpegurl"     // HLS 재생 목록
}
