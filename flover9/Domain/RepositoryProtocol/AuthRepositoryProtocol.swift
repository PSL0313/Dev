//
//  AuthRepositoryProtocol.swift
//  Flover9
//
//  Created by 박선린 on 4/16/26.
//


// MARK: - 인증 데이터 접근 규칙
protocol AuthRepositoryProtocol: Sendable {
    func signInWithApple(
        credential: AppleSignInCredential
    ) async throws -> AuthSession             // Apple 계정으로 로그인

    func fetchCurrentSession() async throws
        -> AuthSession?                       // 현재 저장된 세션 조회

    func signOut() async throws               // 현재 사용자 로그아웃

    func deleteAccount(
        authorizationCode: String
    ) async throws                            // Apple 연결 해제 및 회원탈퇴
}
