//
//  DeleteAccountUseCase.swift
//  flover9
//
//  Created by 박선린 on 7/30/26.
//


// MARK: - 회원탈퇴(수파베이스 Auth 삭제 및 애플 계정 연동 해제)
final class DeleteAccountUseCase: DeleteAccountUseCaseProtocol {

    private let authRepository: AuthRepositoryProtocol
    private let userSessionStore: UserSessionStore

    init(
        authRepository: AuthRepositoryProtocol,
        userSessionStore: UserSessionStore
    ) {
        self.authRepository = authRepository
        self.userSessionStore = userSessionStore
    }

    func execute(credential: AppleSignInCredential) async throws {
        guard let authorizationCode = credential.authorizationCode,
              !authorizationCode.isEmpty else {
            throw AuthError.invalidAppleCredential     // 인증 코드 누락
        }
        try await authRepository.deleteAccount(
            authorizationCode: authorizationCode
        )
        await userSessionStore.clear()                 // 접수 완료 후 메모리 세션 제거
    }
}
