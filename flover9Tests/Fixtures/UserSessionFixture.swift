//
//  UserSessionFixture.swift
//  flover9Tests
//

import Foundation
@testable import flover9

// MARK: - 세션 복원 테스트에서 반복 사용하는 데이터 생성 도구
enum UserSessionFixture {
    // MARK: - 테스트용 인증 세션 생성
    static func makeSession(
        userID: UUID = UUID()
    ) -> AuthSession {
        AuthSession(
            userID: userID,                              // 지정된 테스트 사용자 ID
            accessToken: "test-access-token",            // 외부 요청에 사용하지 않는 가짜 토큰
            expiresAt: Date(timeIntervalSince1970: 2_000_000_000) // 고정된 미래 만료 시각
        )
    }

    // MARK: - 테스트용 사용자 프로필 생성
    static func makeProfile(
        id: UUID = UUID(),
        nickname: String? = "테스트 사용자"
    ) -> UserProfile {
        let date = Date(timeIntervalSince1970: 1_800_000_000) // 비교 가능한 고정 시각

        return UserProfile(
            id: id,                                     // 지정된 테스트 사용자 ID
            nickname: nickname,                         // 지정된 테스트 닉네임
            role: .user,                                // 기본 사용자 권한
            profileImageURL: nil,                       // 프로필 이미지 없음
            createdAt: date,                            // 고정된 생성 시각
            updatedAt: date                             // 고정된 수정 시각
        )
    }
}
