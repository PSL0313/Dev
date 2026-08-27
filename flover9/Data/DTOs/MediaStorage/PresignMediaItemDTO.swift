//
//  PresignMediaItemDTO.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//



nonisolated struct PresignMediaItemDTO: Encodable, Sendable {
    let contentType: String
    let fileSizeBytes: Int64
    let sortOrder: Int
}