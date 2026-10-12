//
//  ScheduleCacheProtocol.swift
//  flover9
//
//  Created by 박선린 on 9/16/26.
//
import Foundation

// MARK: - 앱 실행 중 일정 DTO를 메모리에 보관하는 캐시 규약
protocol ScheduleCacheProtocol: Actor {
    /// nil은 미조회, 빈 배열은 조회 결과가 없음을 의미한다.
    func covers() -> [ScheduleDTO]?
    func schedule(for scheduleID: UUID) -> ScheduleDTO?
    func detail(for scheduleID: UUID) -> ScheduleDetailResponseDTO?
    func fetchSchedules(on date: Date) -> [ScheduleDTO]?
    func fetchScheduleStartDates(year: Int, month: Int) -> [Date]?

    func saveCovers(_ schedules: [ScheduleDTO])
    func saveDetail(_ response: ScheduleDetailResponseDTO)
    func storeSchedules(_ schedules: [ScheduleDTO], for date: Date)
    func storeScheduleDates(_ dates: [Date], year: Int, month: Int)
    
    func resetCovers()
    func reset(_ scheduleID: UUID)
    func resetAll()
}
