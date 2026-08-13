import Foundation

// MARK: - 일정의 성격을 구분하는 도메인 모델
nonisolated enum ScheduleType: String, Sendable, Equatable, Codable {
    case event                         // 공연, 팬미팅 등의 행사
    case broadcast                     // 방송 출연 일정
    case youtubeUpload = "youtube_upload" // 유튜브 콘텐츠 공개 일정
    case release                       // 음원 또는 앨범 발매 일정
    case popupStore = "popup_store"   // 팝업스토어 운영 일정
    case anniversary                   // 기념일
    case other                         // 위 분류에 포함되지 않는 일정
}
