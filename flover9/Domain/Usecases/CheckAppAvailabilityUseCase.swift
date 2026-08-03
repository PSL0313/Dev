//
//  CheckAppAvailabilityUseCase.swift
//  flover9
//
//  Created by 박선린 on 8/3/26.
//


// MARK: - 점검 상태와 최소 지원 버전을 확인하는 UseCase
final class CheckAppAvailabilityUseCase:
    CheckAppAvailabilityUseCaseProtocol,
    Sendable
{
    private let repository: RemoteConfigRepositoryProtocol // 원격 설정 저장소

    init(repository: RemoteConfigRepositoryProtocol) {
        self.repository = repository // 저장소 주입
    }

    func execute() async -> AppAvailability {
        await repository.fetchAppAvailability() // 원격 운영 상태 조회
    }
}
