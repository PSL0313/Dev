//
//  ScheduleDetailContent.swift
//  flover9
//
//  Created by 박선린 on 9/10/26.
//
import Foundation

// MARK: - 일정 상세 화면에 필요한 데이터를 한 번에 전달하는 도메인 모델
nonisolated struct ScheduleDetailContent: Sendable, Equatable {
    let schedule: ScheduleEntity             // 일정 제목과 시간 등의 요약 정보
    let detail: ScheduleDetailEntity?        // 장소와 설명 등의 선택 상세 정보
    let media: [ScheduleMediaEntity]         // 표시 순서대로 정렬된 첨부 미디어

    // 공통값과 일정별 예외를 조합합니다. 주소/좌표는 서로 다른 장소가 섞이지 않게 묶어서 선택합니다.
    func resolvingEventDefaults() -> ScheduleDetailContent {
        let event = schedule.event
        let hasLocationOverride = detail?.address != nil || detail?.roadAddress != nil
            || detail?.latitude != nil || detail?.longitude != nil
            || (detail?.applePlaceID != nil && detail?.applePlaceID != event.applePlaceID)
            || (schedule.venueName != nil && schedule.venueName != event.venueName)
        let resolved = ScheduleDetailEntity(
            scheduleID: schedule.id,
            description: detail?.description ?? event.description,
            address: hasLocationOverride ? detail?.address : event.address,
            roadAddress: hasLocationOverride ? detail?.roadAddress : event.roadAddress,
            latitude: hasLocationOverride ? detail?.latitude : event.latitude,
            longitude: hasLocationOverride ? detail?.longitude : event.longitude,
            notice: detail?.notice ?? event.notice,
            reservationURL: detail?.reservationURL ?? event.reservationURL,
            externalURL: detail?.externalURL ?? event.externalURL,
            createdAt: detail?.createdAt ?? event.createdAt,
            updatedAt: max(detail?.updatedAt ?? event.updatedAt, event.updatedAt),
            applePlaceID: hasLocationOverride ? detail?.applePlaceID : (detail?.applePlaceID ?? event.applePlaceID)
        )
        return ScheduleDetailContent(schedule: schedule, detail: resolved, media: media)
    }
}
