import Foundation

// MARK: - 일정 목록과 홈 화면에서 사용하는 일정 요약 정보
nonisolated struct ScheduleEntity: Identifiable, Sendable, Equatable, Hashable {
    let id: UUID                       // 일정 식별자
    let title: String                  // 일정 제목
    let venueName: String?             // 목록에 표시할 간단한 장소명
    let type: ScheduleType             // 일정 종류
    let status: ScheduleStatus         // 일정 진행 상태
    let startAt: Date                  // 일정 시작 시각
    let endAt: Date?                   // 일정 종료 시각
    let isAllDay: Bool                 // 정확한 시간이 없는 종일 일정 여부
    let operationStartTime: String?    // 여러 날 운영되는 일정의 일일 시작 시간
    let operationEndTime: String?      // 여러 날 운영되는 일정의 일일 종료 시간
    let timeZone: String               // 일정 표시 기준 IANA 시간대
    let thumbnailURL: URL?             // 목록 대표 이미지 주소
    let externalURL: URL?              // 외부 페이지로 바로 이동할 주소
    let externalContentID: String?     // 유튜브 영상 ID 등의 외부 식별자
    let participantMemberCodes: [String]? // nil이면 플로버 참여, 값이 있으면 참여 멤버 코드
    let createdAt: Date                // 데이터 생성 시각
    let updatedAt: Date                // 데이터 수정 시각
}
