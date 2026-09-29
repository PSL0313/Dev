//
//  WallpaperDownloadStub.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Supabase
import UIKit
import XCTest
@testable import flover9

// 다운로드 실패 경로를 확인하기 위한 테스트용 저장소입니다.
final class WallpaperDownloadStub: WallpaperDownloadRepositoryProtocol {
    func download(_ url: URL) async throws -> URL { throw URLError(.badURL) }
}
