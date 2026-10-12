//
//  ScheduleRemoteDataSourceTests.swift.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

import XCTest
import Supabase
@testable import flover9

final class ScheduleRemoteDataSourceTests: XCTestCase {
    @MainActor
    func test_2026년9월_일정조회에성공한다() async throws {
        // Given
        let sut = SupabaseScheduleRemoteDataSource(
            supabaseClient: SupabaseClient(
                supabaseURL: URL(string: "https://pyqxogwmxfinapgbrkwz.supabase.co")!,
                supabaseKey: "sb_publishable_zzJg3RuzlG5E630LZk71qQ_e3tQn3x3"
            )
        )
        // When
        let result = try await sut.fetchScheduleStartDates(
            year: 2026,
            month: 9
        )
        dump(result)
        // Then
        XCTAssertFalse(result.isEmpty)
    }
    
    @MainActor
    func test_반환된_2026년9월_일정이_정상적이다() async throws {
        // Given
        let sut = SupabaseScheduleRemoteDataSource(
            supabaseClient: SupabaseClient(
                supabaseURL: URL(string: "https://pyqxogwmxfinapgbrkwz.supabase.co")!,
                supabaseKey: "sb_publishable_zzJg3RuzlG5E630LZk71qQ_e3tQn3x3"
            )
        )
        // When
        let result = try await sut.fetchScheduleStartDates(
            year: 2026,
            month: 9
        )
        
        
        
        // Then
        let calendar = Calendar.current

        let monthStart = calendar.date(
            from: DateComponents(
                year: 2026,
                month: 9,
                day: 1
            )
        )!
        

        let nextMonthStart = calendar.date(
            byAdding: .month,
            value: 1,
            to: monthStart
        )!
        
        for scheduleDate in result {
            // 일정이 다음 달이 시작되기 전에 시작했는가?
            XCTAssertTrue(scheduleDate.startAt < nextMonthStart)
        }
    }
    
    func test_아주먼_미래() async throws {
        // Given
        let sut = await SupabaseScheduleRemoteDataSource(
            supabaseClient: SupabaseClient(
                supabaseURL: URL(string: "https://pyqxogwmxfinapgbrkwz.supabase.co")!,
                supabaseKey: "sb_publishable_zzJg3RuzlG5E630LZk71qQ_e3tQn3x3"
            )
        )
        // When
        let result = try await sut.fetchScheduleStartDates(
            year: 2099,
            month: 1
        )
        
        // Then
        /// 무조건 비어있어야함
        XCTAssertTrue(result.isEmpty)
    }
}
