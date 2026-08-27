//
//  FeedSource.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//


enum FeedSource: String, Codable,CaseIterable {
    case official       // 소속사
    case instagram      // 인스타
    case fromm          // fromm
    case userUpload     // 사용자가 직접 업로드한 피드
    case otherOffical   // 소속사 외 오피셜


    var displayName: String {
        switch self {
        case .official: return "소속사"
        case .instagram: return "인스타그램"
        case .fromm: return "프롬"
        case .userUpload: return "사용자 업로드"
        case .otherOffical: return "기타"
        }
    }
}
