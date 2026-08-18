//
//  AuthenticateWithAppleUseCaseProtocol.swift
//  flover9
//
//  Created by 박선린 on 7/31/26.
//


// MARK: - Apple 로그인부터 프로필 확인까지 수행하는 UseCase 규칙
protocol AuthenticateWithAppleUseCaseProtocol: Sendable {
    func execute(
        credential: AppleSignInCredential
    ) async throws    // 로그인 결과에 따른 경로 반환
}
