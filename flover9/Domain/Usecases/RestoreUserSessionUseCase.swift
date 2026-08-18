//
//  RestoreUserSessionUseCase.swift
//  flover9
//
//  Created by 박선린 on 7/31/26.
//


// MARK: - 기존 세션과 사용자 프로필을 복원하는 기능
final class RestoreUserSessionUseCase: RestoreUserSessionUseCaseProtocol {

    private let authRepository: AuthRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol
    private let userSessionStore: UserSessionStore

    init(
        authRepository: AuthRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol,
        userSessionStore: UserSessionStore
    ) {
        self.authRepository = authRepository        // 인증 저장소
        self.profileRepository = profileRepository  // 프로필 저장소
        self.userSessionStore = userSessionStore    // 사용자 메모리 저장소
    }

    func execute() async throws -> Bool {
        guard let session =
                try await authRepository.fetchCurrentSession()
        else {
            await userSessionStore.clear()           // 인증 세션이 없으면 이전 사용자 캐시 제거
            return false                            // 저장된 세션 없음
        }

        do {
            let profile = try await profileRepository.fetchMyProfile() // 프로필 조회

            await userSessionStore.save(
                session: session,
                profile: profile
            )                                           // 사용자 정보 저장

            return true                                 // 복원 완료
        } catch {
            await userSessionStore.clear()              // 불완전한 사용자 상태 제거
            throw error
        }
    }
}
