import Foundation

// MARK: - 일정 상세 화면에 필요한 데이터를 한 번에 전달하는 도메인 모델
nonisolated struct ScheduleDetailContent: Sendable, Equatable {
    let schedule: ScheduleEntity             // 일정 제목과 시간 등의 요약 정보
    let detail: ScheduleDetailEntity?        // 장소와 설명 등의 선택 상세 정보
    let media: [ScheduleMediaEntity]         // 표시 순서대로 정렬된 첨부 미디어
}
