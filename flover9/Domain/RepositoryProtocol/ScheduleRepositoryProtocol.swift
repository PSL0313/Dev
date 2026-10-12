//
//  ScheduleRepositoryProtocol.swift
//  flover9
//
//  Created by 박선린 on 9/10/26.
//
import Foundation

// MARK: - 일정 데이터 접근을 Domain 계층에 제공하는 저장소 규약
protocol ScheduleRepositoryProtocol {
    func fetchScheduleCovers() async throws -> [ScheduleEntity] // 표지용 일정 요약 목록 조회
    func fetchScheduleDetail(scheduleID: UUID) async throws -> ScheduleDetailContent // 공통 행사, 일정별 상세, 양쪽 미디어 조회

    func fetchSchedules(on date: Date) async throws -> [ScheduleEntity] // 특정 일자 표지용 일정 요약 목록 조회
    
    // MARK: - 특정 월에 표시할 일정 목록 조회
    func fetchScheduleStartDates(
        year: Int,
        month: Int
    ) async throws -> [Date] // 특정 월의 일정이 있는 일자들 조회
    
    func resetCovers() async
    func reset(scheduleID: UUID) async
    func resetAll() async
}
