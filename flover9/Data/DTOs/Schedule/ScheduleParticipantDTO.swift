import Foundation

// MARK: - schedule_members의 참여 멤버 코드를 전달받는 응답 DTO
nonisolated struct ScheduleParticipantDTO: Decodable, Sendable {
    let memberCode: String                 // schedule_members.member_code

    enum CodingKeys: String, CodingKey {
        case memberCode = "member_code"
    }
}
