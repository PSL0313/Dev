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
