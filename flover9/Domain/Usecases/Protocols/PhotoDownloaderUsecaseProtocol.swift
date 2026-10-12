//
//  PhotoDownloaderUsecaseProtocol.swift
//  flover9
//
//  Created by 박선린 on 10/7/26.
//

import Foundation

enum ImageDownloadDestination {
    case photoLibrary
    case files
}

// MARK: - 이미지 URL, Image, Feed등을 받아서 다운로드하는 객체
protocol PhotoDownloaderUsecaseProtocol {
    func execute(
        imageURL: URL,
        destination: ImageDownloadDestination
    ) async throws
}
