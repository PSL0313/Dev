//
//  ScheduleMediaEntity.swift
//  flover9
//
//  Created by 박선린 on 9/10/26.
//
import Foundation

// MARK: - 일정 상세 화면에 첨부되는 이미지 또는 영상 정보
nonisolated struct ScheduleMediaEntity: Identifiable, Sendable, Equatable {
    let id: UUID                       // 미디어 식별자
    let scheduleID: UUID?              // 개별 일정 미디어의 소유자
    let mediaURL: URL                  // 원본 이미지 또는 영상 주소
    let mediaType: ScheduleMediaType   // 이미지 또는 영상 구분
    let displayRole: ScheduleMediaDisplayRole // 상단 배너 또는 본문 콘텐츠
    let mimeType: ScheduleMIMEType     // 실제 파일 MIME 타입
    let thumbnailURL: URL?             // 영상 등에 사용할 대표 이미지 주소
    let sortOrder: Int                 // 일정 내부 표시 순서
    let width: Int?                    // 원본 가로 크기
    let height: Int?                   // 원본 세로 크기
    let durationSeconds: Double?       // 영상 재생 시간
    let createdAt: Date                // 미디어 데이터 생성 시각
    var eventID: UUID? = nil           // 공통 행사 미디어의 소유자
}
