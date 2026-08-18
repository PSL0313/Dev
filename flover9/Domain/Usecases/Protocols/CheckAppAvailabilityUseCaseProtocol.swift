//
//  CheckAppAvailabilityUseCaseProtocol.swift
//  flover9
//
//  Created by 박선린 on 8/3/26.
//


// MARK: - 앱 접속 가능 여부를 확인하는 UseCase 규격
protocol CheckAppAvailabilityUseCaseProtocol: Sendable {
    func execute() async -> AppAvailability
}
