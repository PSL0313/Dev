//
//  FetchScheduleDetailUseCase.swift
//  flover9
//
//  Created by 박선린 on 9/10/26.
//
import Foundation

// MARK: - 일정 상세 화면에 필요한 데이터를 조회하는 UseCase
final class FetchScheduleDetailUseCase: FetchScheduleDetailUseCaseProtocol {
    private let scheduleRepository: ScheduleRepositoryProtocol // 일정 저장소 규약

    init(scheduleRepository: ScheduleRepositoryProtocol) {
        self.scheduleRepository = scheduleRepository // 주입받은 저장소 보관
    }

    func execute(scheduleID: UUID) async throws -> ScheduleDetailContent {
        let content = try await scheduleRepository.fetchScheduleDetail(
            scheduleID: scheduleID
        )
        return content.resolvingEventDefaults() // 공통 행사 정보 + 선택한 일정의 예외 정보
    }

    /// 다음 조회 시 선택한 일정의 요약·상세·미디어를 다시 가져온다.
    func reset(scheduleID: UUID) async {
        await scheduleRepository.reset(scheduleID: scheduleID)
    }

    func resetAll() async {
        await scheduleRepository.resetAll()
    }
}
