//
//  AuthSession.swift
//  flover9
//
//  Created by 박선린 on 7/30/26.
//
import Foundation

// MARK: - 인증 완료 후 앱에서 사용하는 세션 정보
struct AuthSession: Sendable, Equatable {
    let userID: UUID          // 인증된 사용자 ID
    let accessToken: String   // 서버 요청에 사용하는 접근 토큰
    let expiresAt: Date       // 접근 토큰 만료 시각
}
