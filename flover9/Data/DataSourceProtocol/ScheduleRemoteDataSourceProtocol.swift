//
//  ScheduleRemoteDataSourceProtocol.swift
//  flover9
//
//  Created by 박선린 on 9/16/26.
//
import Foundation

// MARK: - 원격 일정 데이터 조회 기능 규약
@MainActor
protocol ScheduleRemoteDataSourceProtocol: Sendable {
    func fetchScheduleCovers() async throws -> [ScheduleDTO] // 표지에 표시할 일정 요약 목록 조회
    func fetchSchedule(id: UUID) async throws -> ScheduleDTO // 특정 일정의 요약 정보 조회
    func fetchScheduleDetail(scheduleID: UUID) async throws -> ScheduleDetailDTO? // 선택 상세 정보 조회
    func fetchScheduleMedia(scheduleID: UUID, eventID: UUID?) async throws -> [ScheduleMediaDTO] // 첨부 미디어 목록 조회
}
