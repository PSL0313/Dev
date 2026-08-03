//
//  AuthSession+Mapping.swift
//  flover9
//
//  Created by 박선린 on 7/31/26.
//

import Foundation
import Auth

// MARK: - Supabase Session을 Domain AuthSession으로 변환
extension Session {
    nonisolated func toEntity() -> AuthSession {
        AuthSession(
            userID: user.id,                              // 인증된 사용자 ID
            accessToken: accessToken,                     // Supabase 접근 토큰
            expiresAt: Date(timeIntervalSince1970: expiresAt) // 토큰 만료 시각
        )
    }
}
