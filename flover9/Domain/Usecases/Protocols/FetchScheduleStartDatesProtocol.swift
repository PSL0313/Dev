//
//  FetchSch.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//
import Foundation

// MARK: - 캘린더 쪽에서 사용할 Usecase
protocol FetchScheduleStartDatesProtocol {
    // 특정 일자의 스케쥴 조회 조회
    func execute(date: Date) async throws -> [ScheduleEntity]
    
    
    // 특정 월의 일별 일정 유무 조회
    func execute(
        year: Int,
        month: Int
    ) async throws -> [Date]
    
}
