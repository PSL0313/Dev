import Foundation

// MARK: - 일정 DataSource의 DTO를 Domain 모델로 변환하는 저장소
final class ScheduleRepository: ScheduleRepositoryProtocol {
    private let dataSource: ScheduleRemoteDataSourceProtocol // 원격 일정 데이터 제공자

    init(dataSource: ScheduleRemoteDataSourceProtocol) {
        self.dataSource = dataSource // 외부에서 주입받은 데이터 제공자 보관
    }

    // MARK: - 표지에서 사용할 일정 요약 목록 조회
    func fetchScheduleCovers() async throws -> [ScheduleEntity] {
        do {
            let schedules = try await dataSource.getScheduleCovers() // 일정 DTO 목록 조회
            return schedules.map { $0.toEntity() }                   // 참여 멤버 코드를 포함한 Entity로 변환
        } catch let error as ScheduleError {
            throw error                                              // 이미 분류된 Domain 오류 유지
        } catch {
            throw mapScheduleError(error)                            // Data 오류를 Domain 오류로 변환
        }
    }

    // MARK: - 상세 화면에서 사용할 일정 정보 묶음 조회
    func fetchScheduleDetail(scheduleID: UUID) async throws -> ScheduleDetailContent {
        do {
            async let scheduleDTO = dataSource.getSchedule(id: scheduleID) // 일정 요약 병렬 조회
            async let detailDTO = dataSource.getScheduleDetail(scheduleID: scheduleID) // 상세 정보 병렬 조회
            async let mediaDTOs = dataSource.getScheduleMedia(scheduleID: scheduleID) // 미디어 병렬 조회

            let (schedule, detail, media) = try await (
                scheduleDTO,
                detailDTO,
                mediaDTOs
            )

            return ScheduleDetailContent(
                schedule: schedule.toEntity(),                      // 참여 멤버 코드를 포함한 일정 Entity
                detail: detail?.toEntity(),                         // 존재하는 경우 상세 Entity
                media: media.map { $0.toEntity() }                  // 첨부 미디어 Entity 목록
            )
        } catch let error as ScheduleError {
            throw error                                              // 이미 분류된 Domain 오류 유지
        } catch {
            throw mapScheduleError(error)                            // Data 오류를 Domain 오류로 변환
        }
    }

    // MARK: - 범용 Supabase Data 오류를 일정 Domain 오류로 변환
    private func mapScheduleError(_ error: Error) -> ScheduleError {
        guard let dataError = error as? SupabaseDataError else {
            return .unknown                                         // 예상하지 못한 외부 오류
        }

        switch dataError {
        case .network:
            return .networkUnavailable
        case .unauthorized:
            return .permissionDenied
        case .notFound:
            return .notFound
        case .decoding:
            return .invalidScheduleData
        case .database:
            return .serverUnavailable
        case .unknown:
            return .unknown
        }
    }
}
