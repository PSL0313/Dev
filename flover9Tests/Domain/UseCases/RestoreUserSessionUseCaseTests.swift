//
//  RestoreUserSessionUseCaseTests.swift
//  flover9Tests
//

import Foundation
import Testing
@testable import flover9

// MARK: - 기존 세션과 프로필 복원 동작 검증
@Suite("RestoreUserSessionUseCase")
struct RestoreUserSessionUseCaseTests {
    // MARK: - 저장된 인증 세션이 없으면 false를 반환하고 이전 캐시 제거
    @Test("세션이 없으면 이전 사용자 캐시를 제거한다")
    func clearsCachedUserWhenSessionDoesNotExist() async throws {
        let authRepository = MockAuthRepository()       // 인증 테스트 대역
        let profileRepository = MockProfileRepository() // 프로필 테스트 대역
        let userSessionStore = UserSessionStore()       // 검증할 메모리 저장소
        let cachedSession = UserSessionFixture.makeSession()
        let cachedProfile = UserSessionFixture.makeProfile()

        await authRepository.setCurrentSession(nil)     // 저장된 인증 세션 없음
        await userSessionStore.save(
            session: cachedSession,
            profile: cachedProfile
        )                                               // 이전 사용자 캐시 준비

        let sut = await RestoreUserSessionUseCase(
            authRepository: authRepository,
            profileRepository: profileRepository,
            userSessionStore: userSessionStore
        )                                               // 테스트 대상 생성

        let result = try await sut.execute()             // 세션 복원 실행
        let cachedUser = await userSessionStore.currentUser()

        #expect(result == false)                         // 로그인되지 않은 상태 반환
        #expect(cachedUser == nil)                       // 이전 사용자 캐시 제거
    }

    // MARK: - 세션과 프로필이 모두 유효하면 사용자 정보 저장
    @Test("세션과 프로필이 유효하면 사용자 정보를 저장한다")
    func savesUserWhenSessionAndProfileExist() async throws {
        let authRepository = MockAuthRepository()       // 인증 테스트 대역
        let profileRepository = MockProfileRepository() // 프로필 테스트 대역
        let userSessionStore = UserSessionStore()       // 검증할 메모리 저장소
        let userID = UUID()
        let session = UserSessionFixture.makeSession(userID: userID)
        let profile = UserSessionFixture.makeProfile(id: userID)

        await authRepository.setCurrentSession(session) // 복원할 인증 세션 준비
        await profileRepository.setProfile(profile)     // 복원할 프로필 준비

        let sut = await RestoreUserSessionUseCase(
            authRepository: authRepository,
            profileRepository: profileRepository,
            userSessionStore: userSessionStore
        )                                               // 테스트 대상 생성

        let result = try await sut.execute()             // 세션 복원 실행
        let cachedUser = await userSessionStore.currentUser()

        #expect(result == true)                          // 복원 성공 반환
        #expect(cachedUser?.session == session)          // 세션 저장 확인
        #expect(cachedUser?.profile == profile)          // 프로필 저장 확인
    }

    // MARK: - 프로필 조회가 실패하면 캐시를 비우고 동일한 오류 전달
    @Test("프로필 조회 실패 시 캐시를 제거하고 오류를 전달한다")
    func clearsCachedUserAndThrowsWhenProfileFetchFails() async {
        let authRepository = MockAuthRepository()       // 인증 테스트 대역
        let profileRepository = MockProfileRepository() // 프로필 테스트 대역
        let userSessionStore = UserSessionStore()       // 검증할 메모리 저장소
        let session = UserSessionFixture.makeSession()
        let cachedProfile = UserSessionFixture.makeProfile()

        await authRepository.setCurrentSession(session) // 유효한 인증 세션 준비
        await profileRepository.setProfileError(ProfileError.notFound) // 조회 실패 설정
        await userSessionStore.save(
            session: session,
            profile: cachedProfile
        )                                               // 제거 여부 확인용 캐시 준비

        let sut = await RestoreUserSessionUseCase(
            authRepository: authRepository,
            profileRepository: profileRepository,
            userSessionStore: userSessionStore
        )                                               // 테스트 대상 생성

        do {
            _ = try await sut.execute()                  // 실패해야 하는 복원 실행
            Issue.record("ProfileError.notFound가 발생해야 합니다.")
        } catch let error as ProfileError {
            #expect(error == .notFound)                  // Domain 오류 유지 확인
        } catch {
            Issue.record("예상하지 못한 오류: \(error)")
        }

        let cachedUser = await userSessionStore.currentUser()
        #expect(cachedUser == nil)                       // 불완전한 사용자 캐시 제거
    }
}
