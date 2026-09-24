//
//  CompletedMediaUpload.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

// MARK: - R2 직접 업로드가 완료된 파일 정보
nonisolated struct CompletedMediaUpload: Sendable, Equatable {
    let presigned: PresignedMediaUploadDTO
    let etag: String?
}
