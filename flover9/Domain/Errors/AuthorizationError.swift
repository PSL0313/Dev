//
//  AuthorizationError.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

import Foundation

// 권한 조회·변경 실패를 사용자에게 안내하는 오류입니다.
nonisolated enum AuthorizationError: Error, LocalizedError, Sendable, Equatable {
    case sessionExpired // 로그인 세션이 없거나 조회 중 계정이 바뀜
    case denied // 현재 작업 권한 없음
    case conflict // 다른 운영자가 역할을 먼저 변경함
    case invalidInput(String) // 대상·사유 등 입력값 오류
    case unavailable // 서버 조회 또는 응답 확인 실패

    var errorDescription: String? {
        switch self {
        case .sessionExpired: "로그인 정보를 다시 확인해 주세요."
        case .denied: "이 작업을 수행할 권한이 없어요. 권한을 다시 확인해 주세요."
        case .conflict: "회원의 역할이 변경됐어요. 새로고침한 역할을 확인한 뒤 다시 진행해 주세요."
        case .invalidInput(let message): message
        case .unavailable: "권한 처리 결과를 확인하지 못했어요. 목록을 새로고침한 뒤 확인해 주세요."
        }
    }
}
