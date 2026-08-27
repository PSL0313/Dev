import Foundation

// MARK: - 피드 파일 업로드와 DB 일괄 확정을 조율하는 Repository
final class MediaStorageRepository: MediaStorageRepositoryProtocol, @unchecked Sendable {
    private let dataSource: MediaStorageRemoteDataSourceProtocol
    private let maximumFileSizeBytes: Int64

    init(
        dataSource: MediaStorageRemoteDataSourceProtocol,
        maximumFileSizeBytes: Int64 = 1_073_741_824
    ) {
        self.dataSource = dataSource
        self.maximumFileSizeBytes = maximumFileSizeBytes
    }

    func createFeed(_ draft: FeedUploadDraft) async throws -> FeedUploadResultEntity {
        do {
            try validate(draft)

            let presignResponse = try await dataSource.presignFeedBatch(
                request: PresignFeedBatchRequestDTO(
                    feedID: draft.id,
                    media: draft.media.map {
                        PresignMediaItemDTO(
                            contentType: $0.contentType.rawValue,
                            fileSizeBytes: $0.fileSizeBytes,
                            sortOrder: $0.sortOrder
                        )
                    }
                )
            )

            let objectKeys = presignResponse.uploads.map { $0.objectKey }

            do {
                let completed = try await uploadAll(
                    files: draft.media,
                    uploads: presignResponse.uploads
                )
                let completedByOrder: [Int: CompletedMediaUpload] = Dictionary(
                    uniqueKeysWithValues: completed.map {
                        ($0.presigned.sortOrder, $0)
                    }
                )

                let finalizeRequest = FinalizeFeedBatchRequestDTO(
                    uploadSessionID: presignResponse.uploadSessionID,
                    feedID: draft.id,
                    title: draft.title,
                    sourceName: draft.sourceName,
                    description: draft.description,
                    captureDate: ISO8601DateFormatter().string(from: draft.captureDate),
                    source: draft.source,
                    permalink: draft.permalink.absoluteString,
                    memberCodes: draft.memberCodes.map(\.rawValue),
                    media: try draft.media.map { file in
                        guard let upload = completedByOrder[file.sortOrder] else {
                            throw MediaUploadError.uploadFailed
                        }
                        return FinalizeFeedMediaItemDTO(
                            objectKey: upload.presigned.objectKey,
                            contentType: file.contentType.rawValue,
                            fileSizeBytes: file.fileSizeBytes,
                            sortOrder: file.sortOrder,
                            checksumSHA256: file.checksumSHA256,
                            etag: upload.etag
                        )
                    }
                )

                let response = try await dataSource.finalizeFeedBatch(
                    request: finalizeRequest
                )

                return FeedUploadResultEntity(
                    feed: try response.feed.toEntity(),
                    mediaCount: response.mediaCount
                )
            } catch {
                _ = try? await dataSource.abortFeedBatch(
                    request: AbortFeedBatchRequestDTO(
                        uploadSessionID: presignResponse.uploadSessionID,
                        feedID: draft.id,
                        objectKeys: objectKeys
                    )
                )
                throw error
            }
        } catch let error as MediaUploadError {
            throw error
        } catch is FeedError {
            throw MediaUploadError.finalizationFailed
        } catch {
            throw mapMediaUploadError(error)
        }
    }

    func deleteFeedMedia(mediaID: UUID) async throws {
        do {
            let response = try await dataSource.deleteFeedMedia(
                request: DeleteFeedMediaRequestDTO(mediaID: mediaID)
            )

            guard response.deleted else {
                throw MediaUploadError.serverUnavailable
            }
            if response.cleanupPending {
                throw MediaUploadError.cleanupPending
            }
        } catch let error as MediaUploadError {
            throw error
        } catch {
            throw mapMediaUploadError(error)
        }
    }

    private func uploadAll(
        files: [UploadMediaFile],
        uploads: [PresignedMediaUploadDTO]
    ) async throws -> [CompletedMediaUpload] {
        let filesByOrder = Dictionary(
            uniqueKeysWithValues: files.map { ($0.sortOrder, $0) }
        )

        guard
            uploads.count == files.count,
            uploads.allSatisfy({ filesByOrder[$0.sortOrder] != nil })
        else {
            throw MediaUploadError.serverUnavailable
        }

        return try await withThrowingTaskGroup(
            of: CompletedMediaUpload.self
        ) { group in
            for upload in uploads {
                guard let file = filesByOrder[upload.sortOrder] else { continue }
                group.addTask { [dataSource] in
                    try await dataSource.upload(
                        fileURL: file.fileURL,
                        to: upload
                    )
                }
            }

            var completed: [CompletedMediaUpload] = []
            for try await upload in group {
                completed.append(upload)
            }
            return completed
        }
    }

    private func validate(_ draft: FeedUploadDraft) throws {
        guard !draft.media.isEmpty, draft.media.count <= 20 else {
            throw MediaUploadError.emptyMedia
        }
        guard !draft.memberCodes.isEmpty else {
            throw MediaUploadError.invalidFile
        }
        guard Set(draft.memberCodes).count == draft.memberCodes.count else {
            throw MediaUploadError.invalidFile
        }

        let sortOrders = draft.media.map(\.sortOrder)
        guard Set(sortOrders).count == sortOrders.count else {
            throw MediaUploadError.duplicatedSortOrder
        }

        for file in draft.media {
            guard file.fileURL.isFileURL, file.sortOrder >= 0 else {
                throw MediaUploadError.invalidFile
            }
            guard file.fileSizeBytes > 0 else {
                throw MediaUploadError.invalidFile
            }
            guard file.fileSizeBytes <= maximumFileSizeBytes else {
                throw MediaUploadError.fileTooLarge
            }
        }
    }

    private func mapMediaUploadError(_ error: Error) -> MediaUploadError {
        guard let dataError = error as? SupabaseDataError else {
            return .unknown
        }

        switch dataError {
        case .network:
            return .networkUnavailable
        case .unauthorized:
            return .permissionDenied
        case .notFound:
            return .serverUnavailable
        case .decoding:
            return .finalizationFailed
        case .database:
            return .serverUnavailable
        case .unknown:
            return .uploadFailed
        }
    }
}
