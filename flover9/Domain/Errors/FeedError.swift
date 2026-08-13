//
//  FeedError.swift
//  flover9
//
//  Created by Codex on 8/11/26.
//

// MARK: - 피드 조회 및 변환 과정에서 발생할 수 있는 Domain 오류
nonisolated enum FeedError: Error, Sendable, Equatable {
    case invalidDisplayType            // 지원하지 않는 피드 화면 표시 형식
    case invalidThumbnailURL           // 대표 이미지 주소를 URL로 변환하지 못함
    case invalidMediaURL               // 콘텐츠 주소를 URL로 변환하지 못함
    case unsupportedMediaType          // 앱에서 지원하지 않는 콘텐츠 MIME 타입
    case invalidContentCount           // 콘텐츠 개수가 음수이거나 올바르지 않음
    case invalidFeedData               // 피드 응답 데이터 형식이 올바르지 않음
    case networkUnavailable            // 네트워크에 연결할 수 없음
    case serverUnavailable             // 피드 서버를 사용할 수 없음
    case permissionDenied              // RLS 또는 데이터베이스 권한이 거부됨
    case unknown                       // 분류하지 못한 오류
}

extension FeedError {
    // MARK: - 피드 Domain 오류를 사용자 안내 문구로 변환
    var userMessage: String {
        switch self {
        case .invalidDisplayType, .invalidThumbnailURL,
             .invalidMediaURL, .unsupportedMediaType,
             .invalidContentCount, .invalidFeedData:
            return "피드 데이터 형식이 올바르지 않습니다." // 데이터 변환 실패 안내
        case .networkUnavailable:
            return "네트워크 연결을 확인해 주세요."       // 연결 실패 안내
        case .serverUnavailable:
            return "피드 서버에 연결할 수 없습니다. 잠시 후 다시 시도해 주세요." // 서버 오류 안내
        case .permissionDenied:
            return "피드에 접근할 권한이 없습니다."        // 권한 오류 안내
        case .unknown:
            return "피드를 불러오는 중 알 수 없는 오류가 발생했습니다." // 미분류 오류 안내
        }
    }
}
