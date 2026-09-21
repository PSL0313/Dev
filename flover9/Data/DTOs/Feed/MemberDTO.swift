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
    let frommURL: String?             // Fromm 앱 직접 실행 주소
    let instagramURL: String?         // Instagram 앱 직접 실행 주소
    let birthDate: String?            // 생년월일(yyyy-MM-dd)

    enum CodingKeys: String, CodingKey {
        case code
        case displayName = "display_name"
        case sortOrder = "sort_order"
        case isActive = "is_active"
        case createdAt = "created_at"
        case entityType = "entity_type"
        case profileImageURL = "profile_image_url"
        case frommURL = "fromm_url"
        case instagramURL = "instagram_url"
        case birthDate = "birth_date"
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
            profileImageURL: profileImageURL,
            frommURL: try externalURL(from: frommURL),
            instagramURL: try externalURL(from: instagramURL),
            birthDate: try date(from: birthDate)
        )
    }

    // MARK: - nullable 외부 앱 주소를 URL로 변환
    private nonisolated func externalURL(from rawURL: String?) throws -> URL? {
        guard let rawURL else { return nil }
        guard
            let url = URL(string: rawURL),
            url.scheme != nil
        else {
            throw MemberError.invalidMemberData
        }
        return url
    }

    // MARK: - PostgreSQL date 문자열을 날짜로 변환
    private nonisolated func date(from rawDate: String?) throws -> Date? {
        guard let rawDate else { return nil }

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = false

        guard let date = formatter.date(from: rawDate) else {
            throw MemberError.invalidMemberData
        }
        return date
    }
}
