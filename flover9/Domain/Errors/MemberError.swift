//
//  MemberError.swift
//  flover9
//
//  Created by Codex on 8/11/26.
//

// MARK: - 멤버 조회와 데이터 변환 과정에서 사용하는 Domain 오류
nonisolated enum MemberError: Error, Sendable, Equatable {
    case notFound                  // 요청한 멤버를 찾지 못함
    case invalidEntityType         // 서버의 멤버 분류값이 올바르지 않음
    case invalidProfileImageURL    // 프로필 이미지 주소가 올바르지 않음
    case invalidMemberData         // 멤버 응답을 해석할 수 없음
    case permissionDenied          // RLS 또는 데이터베이스 접근 권한이 없음
    case networkUnavailable        // 네트워크에 연결할 수 없음
    case serverUnavailable         // 서버 요청을 정상 처리할 수 없음
    case unknown                   // 분류하지 못한 오류
}

extension MemberError {
    // MARK: - 멤버 Domain 오류를 사용자 안내 문구로 변환
    nonisolated var userMessage: String {
        switch self {
        case .notFound:
            return "멤버 정보를 찾을 수 없습니다."
        case .invalidEntityType, .invalidProfileImageURL, .invalidMemberData:
            return "멤버 정보의 형식이 올바르지 않습니다."
        case .permissionDenied:
            return "멤버 정보에 접근할 권한이 없습니다."
        case .networkUnavailable:
            return "네트워크 연결을 확인해 주세요."
        case .serverUnavailable:
            return "멤버 서버에 연결할 수 없습니다. 잠시 후 다시 시도해 주세요."
        case .unknown:
            return "멤버 정보를 불러오는 중 알 수 없는 오류가 발생했습니다."
        }
    }
}
