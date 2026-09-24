//
//  AdminEditorMode.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

import Foundation

// MARK: - 생성과 수정을 구분해 잘못된 덮어쓰기 방지
enum AdminEditorMode {
    case newFeed
    case editFeed(FeedEntity)
    case newSchedule(ScheduleEventEntity)
    case editSchedule(ScheduleEntity)
    case newEvent
    case editEvent(ScheduleEventEntity)

    var title: String {
        switch self {
        case .newFeed: return "새 피드"
        case .editFeed: return "피드 수정"
        case .newSchedule: return "새 일정"
        case .editSchedule: return "일정 수정"
        case .newEvent: return "새 행사"
        case .editEvent: return "행사 수정"
        }
    }

    var isNew: Bool {
        switch self {
        case .newFeed, .newSchedule, .newEvent: return true
        default: return false
        }
    }

    var existingContent: AdminContent? {
        switch self {
        case .editFeed(let value): return .feed(value)
        case .editSchedule(let value): return .schedule(value)
        case .editEvent(let value): return .event(value)
        default: return nil
        }
    }
}
