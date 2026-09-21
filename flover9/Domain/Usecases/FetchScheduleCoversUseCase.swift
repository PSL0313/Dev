//
//  FetchScheduleCoversUseCase.swift
//  flover9
//
//  Created by 박선린 on 9/10/26.
//
// MARK: - 표지에서 사용할 일정 요약 목록을 조회하는 UseCase
final class FetchScheduleCoversUseCase: FetchScheduleCoversUseCaseProtocol {
    private let scheduleRepository: ScheduleRepositoryProtocol // 일정 저장소 규약

    init(scheduleRepository: ScheduleRepositoryProtocol) {
        self.scheduleRepository = scheduleRepository // 주입받은 저장소 보관
    }

    func execute() async throws -> [ScheduleEntity] {
        try await scheduleRepository.fetchScheduleCovers() // 일정 요약 목록 조회
    }
    
    func execute(_ members: [MemberEntity]) async throws -> [HomeScheduleCardModel] {
        let scheduleEntities = try await execute()
        return HomeScheduleCardModel.makes(from: scheduleEntities, members: members)
    }

    /// 다음 조회 시 가까운 일정 목록을 원격에서 다시 가져온다.
    func reset() async {
        await scheduleRepository.resetCovers()
    }

    func resetAll() async {
        await scheduleRepository.resetAll()
    }
}
