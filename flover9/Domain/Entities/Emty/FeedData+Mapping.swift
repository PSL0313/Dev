//
//  FeedData+Mapping.swift
//  Flover9
//
//  Created by 박선린 on 5/12/26.
//

extension FeedData {
    init(
        feed: FeedRow,
        images: [FeedImageRow],
        members: [FeedMemberRow]
    ) {
        self.id = feed.id
        self.userId = feed.userId
        self.email = feed.email
        self.title = feed.title
        self.sourceName = feed.sourceName
        self.description = feed.description
        self.captureDate = feed.captureDate
        self.uploadedAt = feed.uploadedAt
        self.imageURLs = images
            .sorted { $0.sortOrder < $1.sortOrder }
            .map(\.imageURL)
        self.members = members.map(\.member)
        self.source = feed.source
    }
}
