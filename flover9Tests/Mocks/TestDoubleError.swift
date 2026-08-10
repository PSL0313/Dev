//
//  TestDoubleError.swift
//  flover9Tests
//

import Foundation

// MARK: - 테스트 대역에 필요한 값이 준비되지 않았을 때 사용하는 오류
enum TestDoubleError: Error, Sendable {
    case unconfigured                     // 테스트에 필요한 반환값이 설정되지 않음
}
