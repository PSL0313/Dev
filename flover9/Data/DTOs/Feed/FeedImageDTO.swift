//
//  FeedImageDTO.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//
import Foundation

// MARK: - Supabase의 feed_images 행을 전달받는 응답 DTO
nonisolated struct FeedImageDTO: Decodable, Sendable {
    let id: UUID                       // feed_images.id
    let feedId: UUID                   // feed_images.feed_id
    let imageURL: String               // feed_images.image_url
    let sortOrder: Int                 // feed_images.sort_order
    let objectKey: String              // R2에 저장된 객체 키
    let contentType: String            // 파일의 MIME 타입
    let fileSize: Int64                // 파일 크기
    let checksumSHA256: String?        // 파일 무결성 검사용 해시
    let etag: String?                  // 저장소 객체 버전 식별값
    let uploadedAt: Date               // 업로드 완료 시각

    enum CodingKeys: String, CodingKey {
        case id
        case feedId = "feed_id"
        case imageURL = "image_url"
        case sortOrder = "sort_order"
        case objectKey = "object_key"
        case contentType = "content_type"
        case fileSize = "file_size"
        case checksumSHA256 = "checksum_sha256"
        case etag
        case uploadedAt = "uploaded_at"
    }
}

extension FeedImageDTO {
    // MARK: - 피드 미디어 응답 DTO를 Domain Entity로 변환
    nonisolated func toEntity() throws -> FeedImageEntity {
        guard let mediaURL = URL(string: imageURL) else {
            throw FeedError.invalidMediaURL                  // 잘못된 콘텐츠 주소 차단
        }

        guard let mediaType = FeedMediaType(rawValue: contentType) else {
            throw FeedError.unsupportedMediaType             // 지원하지 않는 MIME 타입 차단
        }

        return FeedImageEntity(
            id: id,
            feedId: feedId,
            imageURL: mediaURL,
            sortOrder: sortOrder,
            contentType: mediaType
        )
    }
}
