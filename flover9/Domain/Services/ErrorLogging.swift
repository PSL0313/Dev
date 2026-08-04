//
//  ErrorLogging.swift
//  flover9
//
//  Created by 박선린 on 8/4/26.
//

import Foundation

// MARK: - 앱에서 발생한 오류를 외부 분석 도구에 기록하는 인터페이스
protocol ErrorLogging: Sendable {
    func record(_ error: AuthError) async      // 인증 오류 기록
    func record(_ error: ProfileError) async   // 프로필 오류 기록
}
