//
//  FeedDisplayType.swift
//  flover9
//
//  Created by 박선린 on 8/11/26.
//


// MARK: - 피드를 앱에서 어떤 화면 형태로 보여줄지 나타내는 분류
nonisolated enum FeedDisplayType: String, Codable, Sendable, Equatable {
    case feed       // 일반 피드 형태로 표시
    case shorts     // 세로형 쇼츠 형태로 표시
}
