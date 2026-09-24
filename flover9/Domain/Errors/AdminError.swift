//
//  AdminError.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

import Foundation

// MARK: - 관리자 기능에서 사용하는 Domain 오류
nonisolated enum AdminError: Error, Equatable, Sendable {
    case permissionDenied
    case invalidInput(String)
    case networkUnavailable
    case notFound
    case serverUnavailable
    case saveUnconfirmed

    var userMessage: String {
        switch self {
        case .permissionDenied:
            return "관리자 또는 매니저 계정으로만 이용할 수 있어요."
        case .invalidInput(let message):
            return message
        case .networkUnavailable:
            return "인터넷 연결을 확인한 뒤 다시 시도해 주세요."
        case .notFound:
            return "다른 관리자가 삭제하거나 변경한 항목이에요. 목록을 새로고침해 주세요."
        case .serverUnavailable:
            return "처리를 확인하지 못했어요. 목록에서 반영 여부를 확인한 뒤 다시 시도해 주세요."
        case .saveUnconfirmed:
            return "저장 결과를 확인하지 못했어요. 같은 요청으로 다시 확인하려면 저장을 눌러 주세요. 계속 실패하면 화면을 닫고 목록을 새로고침해 주세요."
        }
    }
}
