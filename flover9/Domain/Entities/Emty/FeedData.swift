//
//  FeedData.swift
//  Flover9
//
//  Created by 박선린 on 4/23/26.
//

import Foundation

// MARK: - FeedData

struct FeedData: Codable, Identifiable {
    let id: UUID
    let userId: UUID?
    let email: String
    let title: String
    let sourceName: String?
    let description: String?
    let captureDate: Date
    let uploadedAt: Date
    let imageURLs: [String]
    let members: [Member]
    let source: FeedSource

    var isOlderThanOneYear: Bool {
        let oneYearInSeconds: TimeInterval = 365 * 24 * 60 * 60
        return Date().timeIntervalSince(captureDate) >= oneYearInSeconds
    }
}
