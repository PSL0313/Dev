//
//  ScheduleDetailResponseDTO.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

import Foundation

// MARK: - 일정 상세 조회를 완료한 DTO 묶음
nonisolated struct ScheduleDetailResponseDTO: Sendable {
    let schedule: ScheduleDTO
    let detail: ScheduleDetailDTO?
    let media: [ScheduleMediaDTO]

    func toEntity() -> ScheduleDetailContent {
        ScheduleDetailContent(
            schedule: schedule.toEntity(),
            detail: detail?.toEntity(),
            media: media.sorted {
                if $0.sortOrder == $1.sortOrder {
                    return $0.id.uuidString < $1.id.uuidString
                }
                return $0.sortOrder < $1.sortOrder
            }.map { $0.toEntity() }
        )
    }
}
