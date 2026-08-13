import Foundation

// MARK: - 일정 상세 화면에 필요한 데이터를 조회하는 UseCase
final class FetchScheduleDetailUseCase: FetchScheduleDetailUseCaseProtocol {
    private let scheduleRepository: ScheduleRepositoryProtocol // 일정 저장소 규약

    init(scheduleRepository: ScheduleRepositoryProtocol) {
        self.scheduleRepository = scheduleRepository // 주입받은 저장소 보관
    }

    func execute(scheduleID: UUID) async throws -> ScheduleDetailContent {
        try await scheduleRepository.fetchScheduleDetail(
            scheduleID: scheduleID
        ) // 일정 요약과 상세 정보 및 미디어 조회
    }
}
