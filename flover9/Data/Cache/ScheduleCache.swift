//
//  ScheduleCache.swift
//  flover9
//
//  Created by 박선린 on 9/16/26.
//
import Foundation

// MARK: - FeedCache와 동일하게 actor 수명 동안만 유지되는 메모리 캐시
actor ScheduleCache: ScheduleCacheProtocol {
    private var cachedCovers: [ScheduleDTO]?
    private var detailsByScheduleID: [UUID: ScheduleDetailResponseDTO] = [:]

    // MARK: - Read
    func covers() -> [ScheduleDTO]? {
        cachedCovers
    }

    func schedule(for scheduleID: UUID) -> ScheduleDTO? {
        detailsByScheduleID[scheduleID]?.schedule
            ?? cachedCovers?.first { $0.id == scheduleID }
    }

    func detail(for scheduleID: UUID) -> ScheduleDetailResponseDTO? {
        detailsByScheduleID[scheduleID]
    }

    // MARK: - Write
    func saveCovers(_ schedules: [ScheduleDTO]) {
        cachedCovers = schedules
    }

    /// 선택 상세가 nil이거나 미디어가 비어 있어도 조회 완료된 결과로 저장한다.
    func saveDetail(_ response: ScheduleDetailResponseDTO) {
        detailsByScheduleID[response.schedule.id] = response
    }

    // MARK: - Reset
    /// FeedCache의 목록 초기화처럼 상세 캐시는 유지한다.
    func resetCovers() {
        cachedCovers = nil
    }

    /// 변경된 일정이 목록에도 포함될 수 있으므로 목록을 함께 초기화한다.
    func reset(_ scheduleID: UUID) {
        cachedCovers = nil
        detailsByScheduleID[scheduleID] = nil
    }

    func resetAll() {
        cachedCovers = nil
        detailsByScheduleID.removeAll()
    }
}
