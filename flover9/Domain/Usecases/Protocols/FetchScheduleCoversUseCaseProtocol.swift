// MARK: - 표지에서 사용할 일정 요약 목록 조회 기능 규약
protocol FetchScheduleCoversUseCaseProtocol {
    func execute() async throws -> [ScheduleEntity] // 일정 요약 목록 반환
    
    func execute(_ members: [MemberEntity]) async throws -> [HomeScheduleCardModel] // 일정 요약 목록 반환
}
