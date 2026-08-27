//
//  MediaStorageRemoteDataSourceProtocol.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//

import Foundation

// MARK: - Edge Function과 R2 직접 업로드를 담당하는 DataSource 규약
protocol MediaStorageRemoteDataSourceProtocol: Sendable {
    func presignFeedBatch(
        request: PresignFeedBatchRequestDTO
    ) async throws -> PresignFeedBatchResponseDTO

    func upload(
        fileURL: URL,
        to upload: PresignedMediaUploadDTO
    ) async throws -> CompletedMediaUpload

    func finalizeFeedBatch(
        request: FinalizeFeedBatchRequestDTO
    ) async throws -> FinalizeFeedBatchResponseDTO

    func abortFeedBatch(
        request: AbortFeedBatchRequestDTO
    ) async throws -> AbortFeedBatchResponseDTO

    func deleteFeedMedia(
        request: DeleteFeedMediaRequestDTO
    ) async throws -> DeleteMediaResponseDTO
}
