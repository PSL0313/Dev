//
//  FeedEntity.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//
import Foundation

// MARK: - 앱의 화면과 비즈니스 로직에서 사용하는 피드 정보
nonisolated struct FeedEntity: Identifiable, Sendable, Equatable {
    let id: UUID                       // 피드 식별자
    let title: String?                 // 피드 제목
    let sourceName: String?            // 콘텐츠 출처 이름
    let description: String?           // 피드 설명
    let captureDate: Date              // 콘텐츠가 촬영된 날짜
    let source: String                 // 원본 콘텐츠 출처
    let permalink: String              // 원본 콘텐츠 고유 주소
    let thumbnailURL: URL?             // 목록에서 사용할 대표 이미지 주소
    let displayType: FeedDisplayType   // 앱 화면에서 사용할 피드 표시 방식
    let contentCount: Int              // 피드에 포함된 전체 콘텐츠 개수
}
