//
//  SupabaseScheduleRemoteDataSource.swift
//  flover9
//
//  Created by 박선린 on 9/16/26.
//
import Foundation
import Supabase

// MARK: - Supabase 일정 테이블 조회를 담당하는 원격 DataSource
final class SupabaseScheduleRemoteDataSource: ScheduleRemoteDataSourceProtocol {
    private let supabaseClient: SupabaseClient // Supabase 요청 클라이언트

    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient // 주입받은 클라이언트 보관
    }

    // 목록과 단일 조회가 같은 요약 DTO를 반환하도록 조회 칼럼을 공유한다.
    private let scheduleColumns = """
    id,
    event_id,
    schedule_events(*),
    venue_name,
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

    // MARK: - 홈탭의 가까운 일정에 표시할 일정 요약 목록 조회
    func fetchScheduleCovers() async throws -> [ScheduleDTO] {
        let now = Date().ISO8601Format()
        do {
            let schedules: [ScheduleDTO] = try await supabaseClient
                .from("schedules")
                .select(scheduleColumns)
                .or("end_at.gt.\(now),and(end_at.is.null,start_at.gte.\(now))")             // 진행 중 포함. 종료가 없는 일정은 시작 시각 기준
                .order("start_at", ascending: true)       // 가까운 일정부터 정렬
                .order("id", ascending: true)            // 같은 시작 시각에도 순서 고정
                .limit(3)                                 // 가까운 일정 3개
                .execute()
                .value

            return schedules
        } catch {
            throw SupabaseDataError.map(error)
        }
    }

    // MARK: - 식별자에 해당하는 일정 요약 정보 조회
    func fetchSchedule(id: UUID) async throws -> ScheduleDTO {
        do {
            return try await supabaseClient
                .from("schedules")
                .select(scheduleColumns)
                .eq("id", value: id)
                .single()
                .execute()
                .value
        } catch {
            throw SupabaseDataError.map(error)
        }
    }

    // MARK: - 일정에 연결된 선택 상세 정보 조회
    func fetchScheduleDetail(scheduleID: UUID) async throws -> ScheduleDetailDTO? {
        do {
            let details: [ScheduleDetailDTO] = try await supabaseClient
                .from("schedule_details")
                .select("*") // 새 Optional 칼럼은 DB 적용 전 누락되어도 디코딩 가능
                .eq("schedule_id", value: scheduleID)
                .limit(1)
                .execute()
                .value

            return details.first
        } catch {
            throw SupabaseDataError.map(error)
        }
    }

    // MARK: - 일정에 연결된 첨부 미디어 목록 조회
    func fetchScheduleMedia(scheduleID: UUID, eventID: UUID?) async throws -> [ScheduleMediaDTO] {
        do {
            let ownershipFilter = eventID.map {
                "schedule_id.eq.\(scheduleID.uuidString),event_id.eq.\($0.uuidString)"
            } ?? "schedule_id.eq.\(scheduleID.uuidString)"
            return try await supabaseClient
                .from("schedule_media")
                .select(
                    """
                    id,
                    schedule_id,
                    event_id,
                    media_url,
                    media_type,
                    display_role,
                    mime_type,
                    thumbnail_url,
                    sort_order,
                    width,
                    height,
                    duration_seconds,
                    created_at
                    """
                )
                .or(ownershipFilter)
                .order("sort_order", ascending: true)
                .order("id", ascending: true)
                .execute()
                .value
        } catch {
            throw SupabaseDataError.map(error)
        }
    }
}
