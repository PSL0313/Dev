//
//  MockAuthRepository.swift
//  flover9Tests
//

import Foundation
@testable import flover9

// MARK: - 인증 결과를 원하는 상황으로 제어하는 테스트용 Repository
actor MockAuthRepository: AuthRepositoryProtocol {
    private var currentSession: AuthSession?             // 세션 조회 시 반환할 값
    private var currentSessionError: (any Error)?        // 세션 조회 시 던질 오류

    // MARK: - 세션 조회 결과 설정
    func setCurrentSession(_ session: AuthSession?) {
        currentSession = session                         // 테스트용 세션 보관
        currentSessionError = nil                        // 기존 오류 설정 제거
    }

    // MARK: - 세션 조회 오류 설정
    func setCurrentSessionError(_ error: any Error) {
        currentSessionError = error                      // 테스트용 오류 보관
    }

    // MARK: - Apple 로그인은 현재 테스트 범위에서 사용하지 않음
    func signInWithApple(
        credential: AppleSignInCredential
    ) async throws -> AuthSession {
        throw TestDoubleError.unconfigured               // 잘못 호출되면 테스트 실패 유도
    }

    // MARK: - 설정된 현재 세션 반환
    func fetchCurrentSession() async throws -> AuthSession? {
        if let currentSessionError {
            throw currentSessionError                    // 설정된 오류 전달
        }

        return currentSession                            // 설정된 세션 전달
    }

    // MARK: - 로그아웃은 현재 테스트 범위에서 사용하지 않음
    func signOut() async throws {
        throw TestDoubleError.unconfigured               // 잘못 호출되면 테스트 실패 유도
    }

    // MARK: - 회원탈퇴는 현재 테스트 범위에서 사용하지 않음
    func deleteAccount(
        authorizationCode: String
    ) async throws {
        throw TestDoubleError.unconfigured               // 잘못 호출되면 테스트 실패 유도
    }
}
