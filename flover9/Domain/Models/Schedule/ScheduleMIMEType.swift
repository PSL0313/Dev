//
//  ScheduleMIMEType.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//

import Foundation

// MARK: - 일정 첨부 파일에서 지원하는 실제 MIME 타입
nonisolated enum ScheduleMIMEType: String, Sendable, Equatable, Codable {
    case jpeg = "image/jpeg"                       // JPEG 이미지
    case png = "image/png"                         // PNG 이미지
    case webP = "image/webp"                       // WebP 이미지
    case heic = "image/heic"                       // HEIC 이미지
    case mp4 = "video/mp4"                         // MP4 영상
}
