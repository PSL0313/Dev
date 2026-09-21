//
//  CalendarEventModel.swift
//  flover9
//
//  Created by 박선린 on 9/15/26.
//


import Foundation
import CoreLocation
import MapKit

/// 사용자의 아이폰 캘린더에 일정을 추가할 때 사용하는 모델
struct CalendarEventModel {

    let title: String           // 캘린더에 표시할 일정 제목
    let startDate: Date         // 일정 시작 날짜 및 시간
    let endDate: Date?          // 일정 종료 날짜 및 시간
    let isAllDay: Bool          // 종일 일정 여부
    let timeZone: TimeZone?     // 일정이 기준으로 하는 시간대
    let location: String?       // 일정 장소명 또는 주소
    let notes: String?          // 캘린더 상세 메모에 표시할 내용
    let url: URL?               // 예약 페이지 또는 관련 외부 링크
    let mapItem: MKMapItem?     // 맵 아이템
    
}
