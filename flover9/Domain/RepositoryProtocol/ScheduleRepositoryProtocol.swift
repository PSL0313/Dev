import Foundation

// MARK: - 일정 데이터 접근을 Domain 계층에 제공하는 저장소 규약
protocol ScheduleRepositoryProtocol {
    func fetchScheduleCovers() async throws -> [ScheduleEntity] // 표지용 일정 요약 목록 조회
    func fetchScheduleDetail(scheduleID: UUID) async throws -> ScheduleDetailContent // 상세 화면 데이터 조회
}
