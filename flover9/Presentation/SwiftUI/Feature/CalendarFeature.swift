//
//  CalendarFeature.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct CalendarFeature {

    // MARK: - Route, Closure
    var onRoute: ((Route) -> Void)?
    
    enum Route {
        case scheduleDetail(UUID)
    }
    
    
    // MARK: -  Usecase
    private let fetchScheduleCoversUseCase: FetchScheduleCoversUseCaseProtocol
    private let fetchScheduleStartDatesUseCase: FetchScheduleStartDatesProtocol

    init(
        fetchScheduleCoversUseCase: FetchScheduleCoversUseCaseProtocol,
        fetchScheduleStartDatesUseCase: FetchScheduleStartDatesProtocol
    ) {
        self.fetchScheduleCoversUseCase = fetchScheduleCoversUseCase
        self.fetchScheduleStartDatesUseCase = fetchScheduleStartDatesUseCase
    }

    @ObservableState
    struct State: Equatable {
        var month = Date()

        var dates: [Date] = []
        var schedules: [ScheduleEntity] = []

        var isLoading = false
    }

    enum Action {
        case onAppear
        case dayTapped(Date)
        case monthChanged(Date)
        case calendarDataLoaded(
            schedules: [ScheduleEntity],
            dates: [Date]
        )
        case schedulesLoaded([ScheduleEntity])
        case failed(String)
        case scheduleTapped(UUID)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in

            switch action {

            // MARK: - 최초 로딩

            case .onAppear:
                state.isLoading = true

                let date = state.month

                return .run { send in
                    do {
                        let calendar = Calendar.current

                        let year = calendar.component(
                            .year,
                            from: date
                        )

                        let month = calendar.component(
                            .month,
                            from: date
                        )

                        async let schedules =
                            fetchScheduleStartDatesUseCase
                                .execute(date: date)

                        async let dates =
                            fetchScheduleStartDatesUseCase
                                .execute(
                                    year: year,
                                    month: month
                                )

                        let (
                            loadedSchedules,
                            loadedDates
                        ) = try await (
                            schedules,
                            dates
                        )

                        await send(
                            .calendarDataLoaded(
                                schedules: loadedSchedules,
                                dates: loadedDates
                            )
                        )

                    } catch let error as ScheduleError {

                        await send(
                            .failed(error.userMessage)
                        )

                    } catch {

                        await send(
                            .failed(
                                "알 수 없는 오류가 발생했습니다."
                            )
                        )
                    }
                }

            // MARK: - 날짜 선택

            case .dayTapped(let date):
                state.isLoading = true

                return .run { send in
                    do {
                        let schedules =
                            try await fetchScheduleStartDatesUseCase
                                .execute(date: date)

                        await send(
                            .schedulesLoaded(schedules)
                        )

                    } catch let error as ScheduleError {

                        await send(
                            .failed(error.userMessage)
                        )

                    } catch {

                        await send(
                            .failed(
                                "알 수 없는 오류가 발생했습니다."
                            )
                        )
                    }
                }

            // MARK: - 월 변경

            case .monthChanged(let date):
                state.month = date

                state.isLoading = true
                state.dates = []
                state.schedules = []

                return .run { send in
                    do {
                        let calendar = Calendar.current

                        let year = calendar.component(
                            .year,
                            from: date
                        )

                        let month = calendar.component(
                            .month,
                            from: date
                        )

                        async let schedules =
                            fetchScheduleStartDatesUseCase
                                .execute(date: date)

                        async let dates =
                            fetchScheduleStartDatesUseCase
                                .execute(
                                    year: year,
                                    month: month
                                )

                        let (
                            loadedSchedules,
                            loadedDates
                        ) = try await (
                            schedules,
                            dates
                        )

                        await send(
                            .calendarDataLoaded(
                                schedules: loadedSchedules,
                                dates: loadedDates
                            )
                        )

                    } catch let error as ScheduleError {

                        await send(
                            .failed(error.userMessage)
                        )

                    } catch {

                        await send(
                            .failed(
                                "알 수 없는 오류가 발생했습니다."
                            )
                        )
                    }
                }

            // MARK: - 월 데이터 로딩 완료

            case let .calendarDataLoaded(
                schedules,
                dates
            ):
                state.schedules = schedules
                state.dates = dates
                state.isLoading = false

                return .none

            // MARK: - 특정 날짜 일정 로딩 완료

            case .schedulesLoaded(let schedules):
                state.schedules = schedules
                state.isLoading = false

                return .none

            // MARK: - 실패

            case .failed:
                state.isLoading = false

                return .none
            case .scheduleTapped(let id):
                onRoute?(.scheduleDetail(id))
                return .none
            }
        }
    }
}
