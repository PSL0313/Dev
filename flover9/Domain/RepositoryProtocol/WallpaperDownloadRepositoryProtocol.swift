//
//  WallpaperDownloadRepositoryProtocol.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 원본 이미지 URL을 다운로드 파일 URL로 변환하는 저장소 계약입니다.
protocol WallpaperDownloadRepositoryProtocol {
    func download(_ url: URL) async throws -> URL
}
