//
//  ProfileRepositoryProtocol.swift
//  flover9
//
//  Created by 박선린 on 7/31/26.
//
import Foundation

// MARK: - 사용자 프로필 데이터 접근 규칙
protocol ProfileRepositoryProtocol: Sendable {
    func fetchMyProfile() async throws
        -> UserProfile                        // 현재 사용자 프로필 조회

    func updateMyProfile(
        nickname: String?,
        profileImageURL: URL?
    ) async throws -> UserProfile             // 수정된 프로필 반환
}
