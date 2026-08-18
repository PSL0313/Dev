//
//  AppAvailabilityError.swift
//  flover9
//
//  Created by 박선린 on 8/3/26.
//


import Foundation

// MARK: - 앱 운영 상태를 확인하는 과정에서 발생할 수 있는 오류
enum AppAvailabilityError: Error, Sendable, Equatable {
    case networkUnavailable       // 네트워크에 연결할 수 없음
    case serverUnavailable        // Remote Config 서버를 사용할 수 없음
    case invalidConfiguration     // 원격 설정값의 형식이 올바르지 않음
    case fetchFailed              // 원격 설정을 가져오거나 활성화하지 못함
    case unknown                  // 분류하지 못한 오류
}

extension AppAvailabilityError {
    var userMessage: String {
        switch self {
        case .networkUnavailable:
            return "네트워크 연결을 확인해 주세요."
        case .serverUnavailable:
            return "서버와 연결할 수 없습니다. 잠시 후 다시 시도해 보세요."
        case .invalidConfiguration:
            return "remote config 설정이 올바르지 않음. 관리자에게 문의해 주세요."
        case .fetchFailed:
            return "앱 설정 업데이트에 실패했습니다. 잠시 후 다시 시도해 보세요."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해 보세요."
        }
    }
}
