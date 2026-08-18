import Foundation

// MARK: - 일정의 현재 진행 상태를 나타내는 도메인 모델
nonisolated enum ScheduleStatus: String, Sendable, Equatable, Codable {
    case scheduled                     // 예정대로 진행 예정
    case delayed                       // 시작 시간이 지연됨
    case postponed                     // 일정이 추후로 연기됨
    case cancelled                     // 일정이 취소됨
    case completed                     // 일정이 종료됨
}
