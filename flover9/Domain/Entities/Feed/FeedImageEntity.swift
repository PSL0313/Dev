//
//  FeedImageEntity.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//
import Foundation

// MARK: - 앱의 화면과 비즈니스 로직에서 사용하는 피드 미디어 정보
struct FeedImageEntity: Identifiable, Equatable {
    let id: UUID                       // 미디어 식별자
    let feedId: UUID                   // 미디어가 속한 피드 식별자
    let imageURL: URL                  // 이미지 또는 영상 파일 주소
    let sortOrder: Int                 // 피드 내부에서 표시할 순서
    let contentType: FeedMediaType     // 실제 파일의 MIME 타입
}
