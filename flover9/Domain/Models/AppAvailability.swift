//
//  AppAvailability.swift
//  flover9
//
//  Created by 박선린 on 8/3/26.
//


//
//  AppAvailability.swift
//  flover9
//

// MARK: - 앱 실행 시 원격 설정 확인 결과
enum AppAvailability: Sendable, Equatable {
    case available                              // 정상 이용 가능
    case maintenance(message: String)           // 서비스 점검 중
    case updateRequired(minimumVersion: String) // 강제 업데이트 필요
}