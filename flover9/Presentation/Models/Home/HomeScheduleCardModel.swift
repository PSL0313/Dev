//
//  HomeScheduleCardModel.swift
//  flover9
//

import Foundation

// MARK: - 홈 일정 셀이 별도 계산 없이 표시할 화면 데이터
nonisolated struct HomeScheduleCardModel: Identifiable, Sendable, Hashable {
    let id: UUID                         // 일정 식별자
    let dDayText: String                 // D-Day 표시 문구
    let title: String                    // 일정 제목
    let scheduleText: String             // 날짜와 시간 표시 문구
    let venueName: String                // 장소 표시 문구
    let participantImageURLs: [URL?]     // 화면에 표시할 참여 멤버 이미지 주소
    let remainingParticipantCount: Int  // 화면에 표시하지 못한 참여 멤버 수
}

// MARK: - ScheduleEntity를 홈 일정 카드 화면 모델로 변환
extension HomeScheduleCardModel {

    static func make(
        from schedule: ScheduleEntity,
        members: [MemberEntity],
        maximumVisibleParticipants: Int = 5
    ) -> HomeScheduleCardModel {
        
        let now: Date = .now
        
        let timeZone =
            TimeZone(identifier: schedule.timeZone) ?? .current // 일정 기준 시간대

        let participantMembers = makeParticipantMembers(
            memberCodes: schedule.participantMemberCodes,
            members: members
        ) // 참여 멤버 정렬

        let visibleLimit = max(
            0,
            maximumVisibleParticipants
        ) // 음수 제한 방지

        let visibleMembers = Array(
            participantMembers.prefix(visibleLimit)
        ) // 화면에 표시할 멤버

        return HomeScheduleCardModel(
            id: schedule.id,                                    // 일정 식별자
            dDayText: makeDDayText(
                startAt: schedule.startAt,
                now: now,
                timeZone: timeZone
            ),
            title: schedule.title,                              // 일정 제목
            scheduleText: makeScheduleText(
                schedule: schedule,
                timeZone: timeZone
            ),
            venueName: schedule.venueName ?? "장소 미정",        // 장소가 없을 때 기본 문구
            participantImageURLs: visibleMembers.map {
                $0.profileImageURL
            },
            remainingParticipantCount: max(
                0,
                participantMembers.count - visibleMembers.count
            )                                                   // +N으로 표시할 인원
        )
    }
    
    static func makes(
        from schedules: [ScheduleEntity],
        members: [MemberEntity],
        maximumVisibleParticipants: Int = 5
    ) -> [HomeScheduleCardModel] {
        var answer: [HomeScheduleCardModel] = []
        let now: Date = .now
        for schedule in schedules {
            
            
            let timeZone =
            TimeZone(identifier: schedule.timeZone) ?? .current // 일정 기준 시간대
            
            let participantMembers = makeParticipantMembers(
                memberCodes: schedule.participantMemberCodes,
                members: members
            ) // 참여 멤버 정렬
            
            let visibleLimit = max(
                0,
                maximumVisibleParticipants
            ) // 음수 제한 방지
            
            let visibleMembers = Array(
                participantMembers.prefix(visibleLimit)
            ) // 화면에 표시할 멤버
            
            let result = HomeScheduleCardModel(
                id: schedule.id,                                    // 일정 식별자
                dDayText: makeDDayText(
                    startAt: schedule.startAt,
                    now: now,
                    timeZone: timeZone
                ),
                title: schedule.title,                              // 일정 제목
                scheduleText: makeScheduleText(
                    schedule: schedule,
                    timeZone: timeZone
                ),
                venueName: schedule.venueName ?? "장소 미정",        // 장소가 없을 때 기본 문구
                participantImageURLs: visibleMembers.map {
                    $0.profileImageURL
                },
                remainingParticipantCount: max(
                    0,
                    participantMembers.count - visibleMembers.count
                )                                                   // +N으로 표시할 인원
                
            )
            
            answer.append(result)
        }
        return answer
    }
}

private extension HomeScheduleCardModel {

    // MARK: - 참여 멤버 코드를 실제 멤버로 변환하고 공식 순서로 정렬
    static func makeParticipantMembers(
        memberCodes: [String]?,
        members: [MemberEntity]
    ) -> [MemberEntity] {
        guard let memberCodes else {
            return []                                           // 특정 멤버가 없는 일정
        }

        let memberByCode = Dictionary(
            members.map { ($0.code, $0) },
            uniquingKeysWith: { first, _ in first }
        )                                                       // 멤버 코드 기반 조회표

        return memberCodes
            .compactMap { memberByCode[$0] }                    // 코드와 일치하는 멤버 조회
            .sorted { $0.sortOrder < $1.sortOrder }             // 공식 멤버 순서로 정렬
    }

    // MARK: - 일정 시작일을 기준으로 D-Day 문구 생성
    static func makeDDayText(
        startAt: Date,
        now: Date,
        timeZone: TimeZone
    ) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone                            // 일정 지역 날짜 기준 적용

        let today = calendar.startOfDay(for: now)
        let scheduleDay = calendar.startOfDay(for: startAt)

        let remainingDays = calendar.dateComponents(
            [.day],
            from: today,
            to: scheduleDay
        ).day ?? 0

        switch remainingDays {
        case 0:
            return "D-DAY"                                      // 일정 당일

        case 1...:
            return "D-\(remainingDays)"                         // 일정 시작 전

        default:
            return "D+\(abs(remainingDays))"                    // 일정 시작 후
        }
    }

    // MARK: - 일정의 날짜와 시간 표시 문구 생성
    static func makeScheduleText(
        schedule: ScheduleEntity,
        timeZone: TimeZone
    ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "M월 d일 (E)"

        let dateText = dateFormatter.string(
            from: schedule.startAt
        )                                                       // 예: 9월 21일 (월)

        if schedule.isAllDay {
            return "\(dateText) · 종일"                          // 종일 일정
        }

        if let operationStartTime = schedule.operationStartTime {
            return "\(dateText) · \(operationStartTime)"
        }

        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.timeZone = timeZone
        timeFormatter.dateFormat = "a h:mm"

        let startTimeText = timeFormatter.string(
            from: schedule.startAt
        )                                                       // 시작 시간

//        guard let endAt = schedule.endAt else {
//            return "\(dateText) · \(startTimeText)"
//        }

//        let endTimeText = timeFormatter.string(from: endAt)     // 종료 시간

//        return "\(dateText) · \(startTimeText) ~ \(endTimeText)"
        return "\(dateText) · \(startTimeText)"
    }
}
