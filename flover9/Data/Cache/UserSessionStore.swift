//
//  UserSessionStore.swift
//  flover9
//
//  Created by 박선린 on 7/31/26.
//


// MARK: - 로그인한 사용자의 세션과 프로필을 메모리에 보관
actor UserSessionStore {
    private(set) var session: AuthSession?      // 현재 인증 세션
    private(set) var profile: UserProfile?      // 현재 사용자 프로필

    // MARK: - 로그인한 사용자 정보 저장
    func save(session: AuthSession,profile: UserProfile) {
        self.session = session                  // 인증 세션 저장
        self.profile = profile                  // 사용자 프로필 저장
    }

    // MARK: - 현재 사용자 정보 조회
    func currentUser() -> (session: AuthSession,profile: UserProfile)? {
        guard
            let session,
            let profile
        else {
            return nil                          // 저장된 사용자가 없음
        }

        return (session, profile)               // 현재 사용자 정보 반환
    }

    // MARK: - 수정된 프로필 교체
    func updateProfile(_ profile: UserProfile) {
        self.profile = profile                  // 최신 프로필로 교체
    }

    // MARK: - 로그아웃하거나 탈퇴할 때 사용자 정보 제거
    func clear() {
        session = nil                           // 메모리의 세션 제거
        profile = nil                           // 메모리의 프로필 제거
    }
}
