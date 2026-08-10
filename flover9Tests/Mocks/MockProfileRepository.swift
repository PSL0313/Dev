//
//  MockProfileRepository.swift
//  flover9Tests
//

import Foundation
@testable import flover9

// MARK: - 프로필 결과를 원하는 상황으로 제어하는 테스트용 Repository
actor MockProfileRepository: ProfileRepositoryProtocol {
    private var profile: UserProfile?                    // 프로필 조회 시 반환할 값
    private var profileError: (any Error)?               // 프로필 조회 시 던질 오류

    // MARK: - 프로필 조회 결과 설정
    func setProfile(_ profile: UserProfile) {
        self.profile = profile                           // 테스트용 프로필 보관
        profileError = nil                               // 기존 오류 설정 제거
    }

    // MARK: - 프로필 조회 오류 설정
    func setProfileError(_ error: any Error) {
        profileError = error                             // 테스트용 오류 보관
    }

    // MARK: - 설정된 현재 사용자 프로필 반환
    func fetchMyProfile() async throws -> UserProfile {
        if let profileError {
            throw profileError                           // 설정된 오류 전달
        }

        guard let profile else {
            throw TestDoubleError.unconfigured           // 반환값 미설정 알림
        }

        return profile                                   // 설정된 프로필 전달
    }

    // MARK: - 프로필 수정은 현재 테스트 범위에서 사용하지 않음
    func updateMyProfile(
        nickname: String?,
        profileImageURL: URL?
    ) async throws -> UserProfile {
        throw TestDoubleError.unconfigured               // 잘못 호출되면 테스트 실패 유도
    }
}
