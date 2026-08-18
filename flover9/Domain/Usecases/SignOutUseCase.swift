//
//  SignOutUseCase.swift
//  flover9
//
//  Created by 박선린 on 7/31/26.
//


// MARK: - 현재 사용자의 로그아웃을 처리하는 UseCase
final class SignOutUseCase: SignOutUseCaseProtocol  {

    private let authRepository: AuthRepositoryProtocol    // 인증 데이터 접근 객체

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository              // Repository 주입
    }

    // MARK: - 현재 사용자 로그아웃 실행
    func execute() async throws {
        try await authRepository.signOut()                // Supabase 로그아웃 요청
    }
}
