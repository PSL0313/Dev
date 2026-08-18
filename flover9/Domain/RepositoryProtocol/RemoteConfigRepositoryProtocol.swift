//
//  RemoteConfigRepositoryProtocol.swift
//  flover9
//
//  Created by 박선린 on 8/3/26.
//


// MARK: - 앱의 원격 운영 설정을 조회하는 저장소 규격
protocol RemoteConfigRepositoryProtocol: Sendable {
    func fetchAppAvailability() async -> AppAvailability
}
