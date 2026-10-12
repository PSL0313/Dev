//
//  FetchScheduleStartDatesUseCase.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//
import Foundation

final class FetchScheduleStartDatesUseCase: FetchScheduleStartDatesProtocol {

    private let repository: ScheduleRepositoryProtocol

    init(repository: ScheduleRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        year: Int,
        month: Int
    ) async throws -> [Date] {
        try await repository.fetchScheduleStartDates(
            year: year,
            month: month
        )
    }
    
    func execute(date: Date) async throws -> [ScheduleEntity] {
        try await repository.fetchSchedules(on: date)
    }
}
