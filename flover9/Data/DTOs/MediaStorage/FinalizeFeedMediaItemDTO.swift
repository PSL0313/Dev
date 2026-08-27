//
//  FinalizeFeedMediaItemDTO.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//


nonisolated struct FinalizeFeedMediaItemDTO: Encodable, Sendable {
    let objectKey: String
    let contentType: String
    let fileSizeBytes: Int64
    let sortOrder: Int
    let checksumSHA256: String?
    let etag: String?
}