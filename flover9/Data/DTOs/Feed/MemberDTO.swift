//
//  MemberDTO.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//
import Foundation

// MARK: - Supabase의 members 행을 전달받는 응답 DTO
nonisolated struct MemberDTO: Decodable, Sendable {
    let code: String                 // members.code
    let displayName: String          // 화면에 표시할 이름
    let sortOrder: Int               // 멤버 정렬 순서
    let isActive: Bool               // 현재 서비스 노출 여부
    let createdAt: Date              // 행 생성 시각
    let entityType: String           // member 또는 official 분류값
    let profileImageURL: String?     // 프로필 이미지 주소

    enum CodingKeys: String, CodingKey {
        case code
        case displayName = "display_name"
        case sortOrder = "sort_order"
        case isActive = "is_active"
        case createdAt = "created_at"
        case entityType = "entity_type"
        case profileImageURL = "profile_image_url"
    }
}

extension MemberDTO {
    // MARK: - 멤버 응답 DTO를 Domain Entity로 변환
    nonisolated func toEntity() throws -> MemberEntity {
        guard let entityType = MemberEntityType(rawValue: entityType) else {
            throw MemberError.invalidEntityType // 알 수 없는 멤버 분류 차단
        }

        let profileImageURL: URL?

        if let rawURL = self.profileImageURL {
            guard let url = URL(string: rawURL) else {
                throw MemberError.invalidProfileImageURL // 잘못된 이미지 주소 차단
            }
            profileImageURL = url
        } else {
            profileImageURL = nil
        }

        return MemberEntity(
            code: code,
            displayName: displayName,
            sortOrder: sortOrder,
            isActive: isActive,
            createdAt: createdAt,
            entityType: entityType,
            profileImageURL: profileImageURL
        )
    }
}
