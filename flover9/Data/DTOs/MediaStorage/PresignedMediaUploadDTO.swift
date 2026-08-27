//
//  PresignedMediaUploadDTO.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//
import Foundation

nonisolated struct PresignedMediaUploadDTO: Decodable, Sendable, Equatable {
    let sortOrder: Int
    let contentType: String
    let fileSizeBytes: Int64
    let objectKey: String
    let publicURL: URL
    let uploadURL: URL
    let expiresAt: Date
    let requiredHeaders: [String: String]
}
