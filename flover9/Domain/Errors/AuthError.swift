//
//  AuthError.swift
//  flover9
//
//  Created by 박선린 on 7/31/26.
//


// MARK: - 인증 과정에서 발생할 수 있는 Domain 오류
enum AuthError: Error, Sendable, Equatable {
    case cancelled                 // 사용자가 Apple 인증을 취소함
    case unauthenticated           // 로그인된 사용자가 없음
    case invalidAppleCredential    // Apple 인증 정보가 올바르지 않음
    case sessionExpired            // 현재 세션이 만료됨
    case networkUnavailable        // 네트워크에 연결할 수 없음
    case serverUnavailable         // 인증 서버를 사용할 수 없음
    case accountDeletionFailed     // 회원탈퇴 처리에 실패함
    case unknown                   // 분류하지 못한 오류
}

extension AuthError {
    // MARK: - 인증 Domain 오류를 사용자 안내 문구로 변환
    var userMessage: String {
        switch self {
        case .cancelled:
            return "Apple 로그인이 취소되었습니다."
        case .unauthenticated:
            return "로그인 정보를 확인할 수 없습니다."
        case .invalidAppleCredential:
            return "Apple 인증 정보가 올바르지 않습니다."
        case .sessionExpired:
            return "로그인 세션이 만료되었습니다. 다시 시도해 주세요."
        case .networkUnavailable:
            return "네트워크 연결을 확인해 주세요."
        case .serverUnavailable:
            return "로그인 서버에 연결할 수 없습니다. 잠시 후 다시 시도해 주세요."
        case .accountDeletionFailed:
            return "회원탈퇴 처리에 실패했습니다."
        case .unknown:
            return "로그인 중 알 수 없는 오류가 발생했습니다."
        }
    }
}
