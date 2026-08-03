//
//  UserProfile.swift
//  flover9
//
//  Created by 박선린 on 7/29/26.
//
import Foundation

// MARK: - Supabase profiles 테이블의 조회 결과
nonisolated struct ReadUserProfileDTO: Decodable, Sendable {
    let id: UUID                    // 사용자 고유 ID
    let nickname: String?           // 사용자 닉네임
    let profileImageURL: String?    // 프로필 이미지 주소
    let role: String                // 데이터베이스의 사용자 권한
    let createdAt: String           // 프로필 생성 시각
    let updatedAt: String           // 프로필 마지막 수정 시각

    // MARK: - profiles 테이블의 실제 열 이름
    enum CodingKeys: String, CodingKey {
        case id                             // id
        case nickname                       // nickname
        case role                           // role
        case profileImageURL = "profile_image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - 프로필 조회 DTO를 Domain Entity로 변환
extension ReadUserProfileDTO {
    nonisolated func toEntity() throws -> UserProfile {
        guard let userRole = UserRole(rawValue: role) else {
            throw ProfileError.invalidRole       // 잘못된 권한 문자열 차단
        }

        let fractionalFormatter = ISO8601DateFormatter()
        fractionalFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]                                         // Supabase의 소수점 이하 초가 포함된 시간 처리
        
        let standardFormatter = ISO8601DateFormatter() // 소수점 이하 초가 없는 시간 처리
        
        guard
            let createdDate =
                fractionalFormatter.date(from: createdAt)
                ?? standardFormatter.date(from: createdAt),
            let updatedDate =
                fractionalFormatter.date(from: updatedAt)
                ?? standardFormatter.date(from: updatedAt)
        else {
            throw ProfileError.invalidProfileData // 날짜 변환 실패
        }

        let imageURL = profileImageURL.flatMap {
            URL(string: $0)                       // 문자열을 URL로 변환
        }

        return UserProfile(
            id: id,                               // 사용자 ID 전달
            nickname: nickname,                   // 닉네임 전달
            role: userRole,                       // 변환된 사용자 권한 전달
            profileImageURL: imageURL,            // 변환된 이미지 주소 전달
            createdAt: createdDate,               // 변환된 생성 시각 전달
            updatedAt: updatedDate                // 변환된 수정 시각 전달
        )
    }
}
