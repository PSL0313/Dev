//
//  AuthenticateWithAppleUseCase.swift
//  flover9
//
//  Created by 박선린 on 7/31/26.
//


// MARK: - Supabase 로그인과 사용자 프로필 조회를 처리하는 UseCase
final class AuthenticateWithAppleUseCase: AuthenticateWithAppleUseCaseProtocol {

    private let authRepository: AuthRepositoryProtocol          // 인증 데이터 접근
    private let profileRepository: ProfileRepositoryProtocol    // 프로필 데이터 접근
    private let userSessionStore: UserSessionStore              // 사용자 정보 저장소

    init(
        authRepository: AuthRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol,
        userSessionStore: UserSessionStore
    ) {
        self.authRepository = authRepository                    // 인증 Repository 주입
        self.profileRepository = profileRepository              // 프로필 Repository 주입
        self.userSessionStore = userSessionStore                // 사용자 정보 저장소 주입
    }

    // MARK: - Supabase 로그인 후 프로필 상태 확인
    func execute(credential: AppleSignInCredential) async throws {
        let session = try await authRepository.signInWithApple(
            credential: credential                              // Supabase 로그인
        )

        let profile = try await profileRepository.fetchMyProfile() // 내 프로필 조회
        
        await self.userSessionStore.save(session: session, profile: profile)
    }
}
