//
//  DeleteAccountUseCase.swift
//  flover9
//
//  Created by 박선린 on 7/30/26.
//


// MARK: - 회원탈퇴(수파베이스 Auth 삭제 및 애플 계정 연동 해제)
final class DeleteAccountUseCase: DeleteAccountUseCaseProtocol {

    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func execute(credential: AppleSignInCredential) async throws {
        guard let authorizationCode = credential.authorizationCode,
              !authorizationCode.isEmpty else {
            throw AuthError.invalidAppleCredential     // 인증 코드 누락
        }
        try await authRepository.deleteAccount(
            authorizationCode: authorizationCode
        )
    }
}
