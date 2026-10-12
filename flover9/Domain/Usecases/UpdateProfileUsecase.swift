//
//  UpdateProfileUsecase.swift
//  flover9
//
//  Created by 박선린 on 10/6/26.
//



final class UpdateProfileUsecase: UpdateProfileUsecaseProtocol {
    
    private let profileRepository: ProfileRepositoryProtocol    // 프로필 데이터 접근
    private let userSessionStore: UserSessionStore              // 사용자 정보 저장소
    
    init(profileRepository: ProfileRepositoryProtocol, userSessionStore: UserSessionStore) {
        self.profileRepository = profileRepository
        self.userSessionStore = userSessionStore
    }
        
    func update(nickname: String) async throws {
        let profile = try await profileRepository.updateMyProfile(nickname: nickname, profileImageURL: nil)
        await userSessionStore.updateProfile(profile)
    }
    
    func isAvailableNickname(_ nickname: String) async throws -> (String, Bool) {
        return try await profileRepository.searchAvailableNickname(nickName: nickname)
    }
}
