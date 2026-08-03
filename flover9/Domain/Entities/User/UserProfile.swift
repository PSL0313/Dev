//
//  UserProfile.swift
//  flover9
//
//  Created by 박선린 on 7/29/26.
//
import Foundation

nonisolated struct UserProfile: Sendable, Equatable {
    let id: UUID
    let nickname: String?
    let role: UserRole
    let profileImageURL: URL?
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - 사용자 프로필의 상태 판단
extension UserProfile {
    var needsSetup: Bool {
        guard let nickname else {
            return true           // 닉네임이 없으면 초기 설정 필요
        }

        return nickname
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty              // 공백만 있는 닉네임도 초기 설정 필요
    }
}
