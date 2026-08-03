//
//  ProfileError.swift
//  flover9
//
//  Created by 박선린 on 7/31/26.
//


// MARK: - 프로필 처리 과정에서 발생할 수 있는 Domain 오류
nonisolated enum ProfileError: Error, Sendable, Equatable {
    case unauthenticated            // 로그인된 사용자가 없음
    case notFound                   // 사용자 프로필을 찾지 못함
    case invalidNickname            // 닉네임 형식이 올바르지 않음
    case nicknameAlreadyExists      // 이미 사용 중인 닉네임
    case invalidRole                // 잘못된 권한
    case invalidProfileData         // 날짜 변환 실패
    
    case permissionDenied           // RLS 또는 DB 권한 거부
    case networkUnavailable         // 네트워크에 연결할 수 없음
    case serverUnavailable          // 프로필 서버를 사용할 수 없음
    case unknown                    // 분류하지 못한 오류
}

extension ProfileError {
    // MARK: - 프로필 Domain 오류를 사용자 안내 문구로 변환
    var userMessage: String {
        switch self {
        case .unauthenticated:
            return "로그인 세션을 확인할 수 없습니다."
        case .notFound:
            return "사용자 프로필을 찾을 수 없습니다."
        case .invalidNickname:
            return "닉네임 형식이 올바르지 않습니다."
        case .nicknameAlreadyExists:
            return "이미 사용 중인 닉네임입니다."
        case .invalidRole:
            return "사용자 권한 정보가 올바르지 않습니다."
        case .invalidProfileData:
            return "프로필 데이터 형식이 올바르지 않습니다."
        case .permissionDenied:
            return "프로필에 접근할 권한이 없습니다."
        case .networkUnavailable:
            return "네트워크 연결을 확인해 주세요."
        case .serverUnavailable:
            return "프로필 서버에 연결할 수 없습니다. 잠시 후 다시 시도해 주세요."
        case .unknown:
            return "프로필을 불러오는 중 알 수 없는 오류가 발생했습니다."
        }
    }
    
}
