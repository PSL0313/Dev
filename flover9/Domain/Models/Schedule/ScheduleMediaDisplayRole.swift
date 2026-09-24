//
//  ScheduleMediaDisplayRole.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

// 미디어 형식(image/video)과 별개로 화면에서의 표시 용도를 구분합니다.
nonisolated enum ScheduleMediaDisplayRole: String, Codable, Sendable, Equatable {
    case hero       // 상단 배너
    case content    // 본문 콘텐츠
}
