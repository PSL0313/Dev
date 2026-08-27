//
//  FeedMediaType.swift
//  flover9
//
//  Created by Codex on 8/11/26.
//

// MARK: - 피드 내부 콘텐츠의 실제 파일 형식을 나타내는 MIME 타입
nonisolated enum FeedMediaType: String, Codable, Sendable, Equatable {
    case jpeg = "image/jpeg"                              // JPEG 이미지
    case png = "image/png"                                // PNG 이미지
    case webp = "image/webp"                              // WebP 이미지
    case heic = "image/heic"                              // HEIC 이미지
    case mp4 = "video/mp4"                                // MP4 영상

    // MARK: - 이미지로 표시할 수 있는 콘텐츠인지 확인
    var isImage: Bool {
        switch self {
        case .jpeg, .png, .webp, .heic:
            return true                                    // 이미지 MIME 타입
        case .mp4:
            return false                                   // 영상 MIME 타입
        }
    }

    // MARK: - 영상 플레이어로 재생할 콘텐츠인지 확인
    var isVideo: Bool {
        !isImage                                           // 이미지가 아니면 영상으로 처리
    }
}
