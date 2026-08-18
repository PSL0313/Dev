//
//  FeedMemberResponseDTO.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//
import Foundation

// MARK: - Supabase의 feed_members 행을 전달받는 응답 DTO
nonisolated struct FeedMemberResponseDTO: Decodable, Sendable {
    let id: UUID
    let feedId: UUID
    let memberCode: MemberCode

    enum CodingKeys: String, CodingKey {
        case id
        case feedId = "feed_id"
        case memberCode = "member"
    }
}

extension FeedMemberResponseDTO {
    // MARK: - 피드 멤버 응답 DTO를 Domain Entity로 변환
    nonisolated func toEntity() -> FeedMemberEntity {
        FeedMemberEntity(id: self.id, feedId: self.feedId, memberCode: self.memberCode)
    }
}
