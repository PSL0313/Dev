import Foundation
import Supabase

// MARK: - Supabase 일정 테이블 조회를 담당할 원격 DataSource 골격
final class SupabaseScheduleRemoteDataSource: ScheduleRemoteDataSourceProtocol {
    private let supabaseClient: SupabaseClient // Supabase 요청 클라이언트

    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient // 주입받은 클라이언트 보관
    }

    // MARK: - 홈탭의 가까운 일정에 표시할 일정 요약 목록 조회
    func getScheduleCovers() async throws -> [ScheduleDTO] {
        let now = Date().ISO8601Format()
        do {
            let schedules: [ScheduleDTO] = try await supabaseClient
                .from("schedules")
                .select(
                 """
                 id,
                 title,
                 venue_name,
                 schedule_type,
                 status,
                 start_at,
                 end_at,
                 is_all_day,
                 operation_start_time,
                 operation_end_time,
                 timezone,
                 thumbnail_url,
                 external_url,
                 external_content_id,
                 created_at,
                 updated_at,
                 schedule_members (
                     member_code
                 )
                 """
                    )
                .gte("start_at", value: now)             // 현재 시각 이후 일정만 조회
                .order("start_at", ascending: true)       // 가까운 일정부터 정렬
                .limit(3)                                 // 가까운 일정 5개
                .execute()
                .value
            
                return schedules
        } catch {
            throw SupabaseDataError.map(error)
        }
    }

    // MARK: - 식별자에 해당하는 일정 요약 정보 조회
    func getSchedule(id: UUID) async throws -> ScheduleDTO {
        // TODO: schedules 테이블 단일 행 조회를 직접 구현합니다.
        fatalError("getSchedule(id:) 구현 필요")
    }

    // MARK: - 일정에 연결된 선택 상세 정보 조회
    func getScheduleDetail(scheduleID: UUID) async throws -> ScheduleDetailDTO? {
        // TODO: schedule_details 테이블 단일 행 조회를 직접 구현합니다.
        fatalError("getScheduleDetail(scheduleID:) 구현 필요")
    }

    // MARK: - 일정에 연결된 첨부 미디어 목록 조회
    func getScheduleMedia(scheduleID: UUID) async throws -> [ScheduleMediaDTO] {
        // TODO: schedule_media 테이블 목록 조회를 직접 구현합니다.
        fatalError("getScheduleMedia(scheduleID:) 구현 필요")
    }
}
