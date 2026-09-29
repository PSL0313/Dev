//
//  WallpaperError.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 입력 오류, 서버 오류, 저장 결과를 확인하지 못한 상태를 구분합니다.
enum WallpaperError: LocalizedError {
    case validation(String) // 입력 값이나 이미지 조건 검증 실패와 안내 문구
    case server(String) // 서버에서 확인된 실패와 안내 문구
    case uncertain // 응답을 확인하지 못해 같은 요청으로 결과를 재확인해야 하는 상태
    var errorDescription: String? { // 사용자에게 보여줄 오류 안내 문구
        switch self {
        case .validation(let message), .server(let message): message
        case .uncertain: "저장 결과를 확인하지 못했어요. 다시 시도하면 같은 요청의 결과를 확인합니다."
        }
    }
}
