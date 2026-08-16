import Foundation

// MARK: - 일정의 성격을 구분하는 도메인 모델
nonisolated enum ScheduleType: String, Sendable, Equatable, Codable {
    case concert       // 단독·그룹 콘서트, 투어
    case fanMeeting    // 팬미팅
    case fanSigning    // 대면 팬사인회, 영상통화 팬사인회
    case musical       // 뮤지컬
    case festival      // 여러 아티스트가 참여하는 페스티벌·합동 공연
    case broadcast     // 음악방송, 예능, 라디오 등의 방송 출연
    case liveStream    // 유튜브·위버스 등의 실시간 방송
    case release       // 앨범, 음원, OST 발매
    case content       // 유튜브 영상이나 자체 콘텐츠 공개
    case event         // 팝업, 전시, 브랜드 행사 등 특별 행사
    case other         // 분류하기 어려운 일정
}
