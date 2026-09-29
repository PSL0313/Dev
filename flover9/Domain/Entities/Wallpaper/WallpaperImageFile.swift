//
//  WallpaperImageFile.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 선택한 이미지의 원본 바이트와 업로드에 필요한 파일 정보를 보관합니다.
struct WallpaperImageFile {
    let id: UUID // 선택한 파일의 업로드 재시도 상태를 찾는 로컬 식별자
    let data: Data // 재압축하지 않은 이미지 파일 바이트
    let contentType: String // 파일 MIME 형식(image/jpeg, image/png, image/webp)
    let fileName: String // 업로드 요청에 전달할 확장자 포함 파일명
    init(data: Data, contentType: String, fileName: String? = nil) {
        id = UUID()
        self.data = data
        self.contentType = contentType
        self.fileName =
            fileName ?? "image.\(contentType == "image/jpeg" ? "jpg" : contentType == "image/png" ? "png" : "webp")"
    }
}
