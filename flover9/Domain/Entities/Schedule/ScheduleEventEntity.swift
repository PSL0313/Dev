//
//  ScheduleEventEntity.swift
//  flover9
//
//  Created by 박선린 on 9/10/26.
//
import Foundation

// 같은 행사의 여러 일정이 공유하는 콘텐츠. 날짜·상태·참여 멤버는 ScheduleEntity에 둡니다.
nonisolated struct ScheduleEventEntity: Identifiable, Sendable, Equatable, Hashable {
    let id: UUID
    let title: String
    let type: ScheduleType
    let venueName: String?
    let thumbnailURL: URL?
    let description: String?
    let address: String?
    let roadAddress: String?
    let latitude: Double?
    let longitude: Double?
    let notice: String?
    let reservationURL: URL?
    let externalURL: URL?
    let createdAt: Date
    let updatedAt: Date
    var applePlaceID: String? = nil
}
