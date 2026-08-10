//
//  FeedEntity.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//
import Foundation

struct FeedEntity: Identifiable, Equatable {
    let id: UUID
    let title: String?
    let sourceName: String?
    let description: String?
    let captureDate: Date
    let source: String
    let permalink: String

    let images: [FeedImageEntity]
    let members: [FeedMemberEntity]
}
