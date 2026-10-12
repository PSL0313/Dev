//
//  CalendarView.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//
import SwiftUI
import ComposableArchitecture

struct CalendarView: View {

    // MARK: - TCA

    let store: StoreOf<CalendarFeature>


    // MARK: - View Local State

    /// 테스트용 월 페이지 목록
    @State private var months: [Date]

    /// 현재 ScrollView가 보여주고 있는 월
    @State private var visibleMonth: Date?


    // MARK: - Initializer

    init(store: StoreOf<CalendarFeature>) {
        self.store = store

        let calendar = Calendar.current

        let currentMonth = Self.startOfMonth(
            store.month,
            calendar: calendar
        )

        // 현재 월 기준 앞뒤 12개월
        let months = (-12...12).compactMap { offset in
            calendar.date(
                byAdding: .month,
                value: offset,
                to: currentMonth
            )
        }

        self._months = State(
            initialValue: months
        )

        self._visibleMonth = State(
            initialValue: currentMonth
        )
    }


    // MARK: - Body

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(months, id: \.self) { month in
                    monthPage(month)
                        .containerRelativeFrame(.horizontal)
                        .id(month)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $visibleMonth)
        .scrollIndicators(.hidden)
        .onAppear {
            store.send(.onAppear)
        }
        .onChange(of: visibleMonth) { _, newMonth in
            guard let newMonth else {
                return
            }

            guard !Self.isSameMonth(
                newMonth,
                store.month
            ) else {
                return
            }

            store.send(
                .monthChanged(newMonth)
            )
        }
    }
}


// MARK: - Month Page

private extension CalendarView {

    @ViewBuilder
    func monthPage(_ month: Date) -> some View {
        ScrollView(.vertical) {
            VStack(
                alignment: .leading,
                spacing: 20
            ) {
                headerView(month)

                calendarGridView(month)

                Divider()
                    .padding(.vertical, 4)

                scheduleSection
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
    }
}


// MARK: - Header

private extension CalendarView {

    @ViewBuilder
    func headerView(_ month: Date) -> some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            Text(
                month,
                formatter: Self.monthFormatter
            )
            .font(.system(
                size: 28,
                weight: .bold
            ))

            HStack(spacing: 0) {
                ForEach(
                    Array(
                        Self.weekdaySymbols.enumerated()
                    ),
                    id: \.offset
                ) { index, symbol in

                    Text(symbol)
                        .font(.system(
                            size: 13,
                            weight: .semibold
                        ))
                        .foregroundStyle(
                            weekdayColor(index)
                        )
                        .frame(
                            maxWidth: .infinity
                        )
                }
            }
        }
    }

    func weekdayColor(
        _ index: Int
    ) -> Color {
        switch index {
        case 0:
            return .red

        case 6:
            return .blue

        default:
            return .secondary
        }
    }
}


// MARK: - Calendar Grid

private extension CalendarView {

    @ViewBuilder
    func calendarGridView(
        _ month: Date
    ) -> some View {

        let daysInMonth =
            numberOfDays(in: month)

        let firstWeekday =
            firstWeekdayOfMonth(in: month) - 1

        let totalCellCount =
            firstWeekday + daysInMonth

        LazyVGrid(
            columns: Self.calendarColumns,
            spacing: 8
        ) {
            ForEach(
                0..<totalCellCount,
                id: \.self
            ) { index in

                if index < firstWeekday {

                    Color.clear
                        .frame(height: 54)

                } else {

                    let day =
                        index - firstWeekday + 1

                    let date =
                        makeDate(
                            month: month,
                            day: day
                        )

                    DayCell(
                        day: day,
                        isEvent: hasEvent(
                            on: date
                        ),
                        isToday: Calendar.current.isDateInToday(
                            date
                        )
                    )
                    .contentShape(
                        Rectangle()
                    )
                    .onTapGesture {
                        store.send(
                            .dayTapped(date)
                        )
                    }
                }
            }
        }
    }
}


// MARK: - Day Cell

private struct DayCell: View {

    let day: Int
    let isEvent: Bool
    let isToday: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(
                String(day)
            )
            .font(.system(
                size: 15,
                weight: isToday
                    ? .bold
                    : .regular
            ))
            .foregroundStyle(
                isToday
                    ? .primary
                    : .secondary
            )
            .frame(
                width: 30,
                height: 30
            )
            .background {
                if isToday {
                    Circle()
                        .fill(
                            Color.secondary.opacity(0.15)
                        )
                }
            }

            if isEvent {
                Circle()
                    .fill(.primary)
                    .frame(
                        width: 5,
                        height: 5
                    )
            } else {
                Color.clear
                    .frame(
                        width: 5,
                        height: 5
                    )
            }

            Spacer(
                minLength: 0
            )
        }
        .frame(
            maxWidth: .infinity
        )
        .frame(
            height: 54
        )
    }
}


// MARK: - Schedule Section

private extension CalendarView {

    @ViewBuilder
    var scheduleSection: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            HStack {
                Text("일정")
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                Text(
                    "\(store.schedules.count)개"
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }

            if store.isLoading {
                loadingView

            } else if store.schedules.isEmpty {
                emptyView

            } else {
                scheduleList
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }
}


// MARK: - Schedule List

private extension CalendarView {

    @ViewBuilder
    var scheduleList: some View {
        LazyVStack(
            spacing: 12
        ) {
            ForEach(store.schedules) { schedule in
                Button {
                    store.send(.scheduleTapped(schedule.id))
                } label: {
                    ScheduleCoverCell(
                        entity: schedule
                    )
                }

            }
        }
    }
}


// MARK: - Loading View

private extension CalendarView {

    @ViewBuilder
    var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()

            Text(
                "일정을 불러오는 중입니다."
            )
            .font(.footnote)
            .foregroundStyle(
                .secondary
            )
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(.vertical, 40)
    }
}


// MARK: - Empty View

private extension CalendarView {

    @ViewBuilder
    var emptyView: some View {
        VStack(spacing: 10) {
            Image(
                systemName: "calendar.badge.minus"
            )
            .font(.title2)
            .foregroundStyle(
                .secondary
            )

            Text(
                "등록된 일정이 없습니다."
            )
            .font(.subheadline)
            .foregroundStyle(
                .secondary
            )
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(.vertical, 40)
    }
}


// MARK: - Schedule Cover Cell

private struct ScheduleCoverCell: View {

    let entity: ScheduleEntity

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            Text(
                entity.title
            )
            .font(.headline)
            .foregroundStyle(.primary)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )

            if let venueName = entity.venueName,
               !venueName.isEmpty {

                HStack(spacing: 6) {
                    Image(
                        systemName: "mappin.and.ellipse"
                    )
                    .foregroundStyle(.secondary)

                    Text(
                        venueName
                    )
                    .lineLimit(1)
                }
                .font(.subheadline)
                .foregroundStyle(
                    .secondary
                )
            }
        }
        .padding(16)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background {
            RoundedRectangle(
                cornerRadius: 14,
                style: .continuous
            )
            .fill(
                Color.secondary.opacity(0.08)
            )
        }
    }
}


// MARK: - Event Check

private extension CalendarView {

    /// 현재 월의 일정 시작 날짜 중
    /// 해당 날짜가 존재하는지 확인
    func hasEvent(
        on date: Date
    ) -> Bool {
        store.dates.contains { eventDate in
            Calendar.current.isDate(
                eventDate,
                inSameDayAs: date
            )
        }
    }
}


// MARK: - Calendar Helpers

private extension CalendarView {

    func makeDate(
        month: Date,
        day: Int
    ) -> Date {
        let start =
            Self.startOfMonth(
                month,
                calendar: .current
            )

        return Calendar.current.date(
            byAdding: .day,
            value: day - 1,
            to: start
        )!
    }

    func numberOfDays(
        in month: Date
    ) -> Int {
        Calendar.current.range(
            of: .day,
            in: .month,
            for: month
        )?.count ?? 0
    }

    func firstWeekdayOfMonth(
        in month: Date
    ) -> Int {
        let firstDay =
            Self.startOfMonth(
                month,
                calendar: .current
            )

        return Calendar.current.component(
            .weekday,
            from: firstDay
        )
    }
}


// MARK: - Static Helpers

private extension CalendarView {

    static let calendarColumns: [GridItem] = Array(
        repeating: GridItem(
            .flexible(),
            spacing: 4
        ),
        count: 7
    )

    static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()

        formatter.locale = Locale(
            identifier: "ko_KR"
        )

        formatter.dateFormat =
            "yyyy년 M월"

        return formatter
    }()

    static let weekdaySymbols: [String] = {
        var calendar = Calendar.current
        calendar.locale = Locale(
            identifier: "ko_KR"
        )

        return calendar
            .veryShortWeekdaySymbols
    }()

    static func startOfMonth(
        _ date: Date,
        calendar: Calendar
    ) -> Date {
        let components =
            calendar.dateComponents(
                [.year, .month],
                from: date
            )

        return calendar.date(
            from: components
        )!
    }

    static func isSameMonth(
        _ lhs: Date,
        _ rhs: Date
    ) -> Bool {
        Calendar.current.isDate(
            lhs,
            equalTo: rhs,
            toGranularity: .month
        )
    }
}


// MARK: - Preview

#Preview {
    CalendarView(
        store: AppDIContainer()
            .makeStore(initialState: CalendarFeature.State(), feature: AppDIContainer().makeCalendarFeature()
            )
    )
}
