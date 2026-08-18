import Foundation

// MARK: - 일정에 참여하는 주체를 화면과 비즈니스 로직에서 구분하는 모델
nonisolated enum ScheduleParticipation: Sendable, Equatable {
    case flover                                      // 특정 멤버 없이 플로버가 참여하는 일정
    case members([String])                            // 특정 멤버의 코드 목록
}

extension ScheduleEntity {
    // MARK: - 옵셔널 참여 멤버 배열을 의미가 분명한 참여 주체로 변환
    var participation: ScheduleParticipation {
        guard let participantMemberCodes,
              !participantMemberCodes.isEmpty else {
            return .flover                              // nil 또는 빈 배열은 플로버 참여로 해석
        }

        return .members(participantMemberCodes)          // 값이 있으면 특정 멤버 참여로 해석
    }
}
