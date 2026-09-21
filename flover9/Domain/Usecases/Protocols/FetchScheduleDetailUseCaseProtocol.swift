//
//  FetchScheduleDetailUseCaseProtocol.swift
//  flover9
//
//  Created by 박선린 on 9/10/26.
//
import Foundation

// MARK: - 일정 상세 화면에 필요한 데이터 조회 기능 규약
protocol FetchScheduleDetailUseCaseProtocol {
    func execute(scheduleID: UUID) async throws -> ScheduleDetailContent // 상세 데이터 묶음 반환

    func reset(scheduleID: UUID) async
    func resetAll() async
}
