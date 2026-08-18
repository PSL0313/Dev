import Foundation

// MARK: - 일정 상세 화면에서 사용하는 추가 정보
nonisolated struct ScheduleDetailEntity: Sendable, Equatable {
    let scheduleID: UUID               // 연결된 일정 식별자
    let description: String?           // 일정 상세 설명
    let address: String?               // 지번 주소
    let roadAddress: String?           // 도로명 주소
    let latitude: Double?              // MapKit에 사용할 위도
    let longitude: Double?             // MapKit에 사용할 경도
    let notice: String?                // 이용자에게 보여줄 주의사항
    let reservationURL: URL?           // 예매 또는 예약 페이지 주소
    let externalURL: URL?              // 길찾기 등 외부 서비스 주소
    let createdAt: Date                // 상세 데이터 생성 시각
    let updatedAt: Date                // 상세 데이터 수정 시각
}
