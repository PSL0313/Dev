//
//  SupabaseMediaStorageRemoteDataSource.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//

import Foundation
import Supabase

// MARK: - Supabase Edge Function과 R2에 미디어 요청을 전달하는 DataSource
final class SupabaseMediaStorageRemoteDataSource: MediaStorageRemoteDataSourceProtocol, @unchecked Sendable {
    private let supabaseClient: SupabaseClient
    private let urlSession: URLSession

    init(
        supabaseClient: SupabaseClient,
        urlSession: URLSession = .shared
    ) {
        self.supabaseClient = supabaseClient
        self.urlSession = urlSession
    }

    func presignFeedBatch(
        request: PresignFeedBatchRequestDTO
    ) async throws -> PresignFeedBatchResponseDTO {
        do {
            return try await supabaseClient.functions.invoke(
                "media-storage",
                options: FunctionInvokeOptions(body: request),
                decoder: mediaStorageDecoder
            )
        } catch {
            throw SupabaseDataError.map(error)
        }
    }

    func upload(
        fileURL: URL,
        to upload: PresignedMediaUploadDTO
    ) async throws -> CompletedMediaUpload {
        do {
            var request = URLRequest(url: upload.uploadURL)
            request.httpMethod = "PUT"
            upload.requiredHeaders.forEach {
                request.setValue($0.value, forHTTPHeaderField: $0.key)
            }
            request.setValue(
                String(upload.fileSizeBytes),
                forHTTPHeaderField: "Content-Length"
            )

            let (_, response) = try await urlSession.upload(
                for: request,
                fromFile: fileURL
            )

            guard
                let httpResponse = response as? HTTPURLResponse,
                200..<300 ~= httpResponse.statusCode
            else {
                throw URLError(.badServerResponse)
            }

            return CompletedMediaUpload(
                presigned: upload,
                etag: httpResponse.value(forHTTPHeaderField: "ETag")
            )
        } catch {
            throw SupabaseDataError.map(error)
        }
    }

    func finalizeFeedBatch(
        request: FinalizeFeedBatchRequestDTO
    ) async throws -> FinalizeFeedBatchResponseDTO {
        do {
            return try await supabaseClient.functions.invoke(
                "media-storage",
                options: FunctionInvokeOptions(body: request),
                decoder: mediaStorageDecoder
            )
        } catch {
            throw SupabaseDataError.map(error)
        }
    }

    func abortFeedBatch(
        request: AbortFeedBatchRequestDTO
    ) async throws -> AbortFeedBatchResponseDTO {
        do {
            return try await supabaseClient.functions.invoke(
                "media-storage",
                options: FunctionInvokeOptions(body: request),
                decoder: mediaStorageDecoder
            )
        } catch {
            throw SupabaseDataError.map(error)
        }
    }

    func deleteFeedMedia(
        request: DeleteFeedMediaRequestDTO
    ) async throws -> DeleteMediaResponseDTO {
        do {
            return try await supabaseClient.functions.invoke(
                "media-storage",
                options: FunctionInvokeOptions(body: request),
                decoder: mediaStorageDecoder
            )
        } catch {
            throw SupabaseDataError.map(error)
        }
    }

    private var mediaStorageDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            if let date = formatter.date(from: value) {
                return date
            }

            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: value) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO 8601 date"
            )
        }
        return decoder
    }
}
