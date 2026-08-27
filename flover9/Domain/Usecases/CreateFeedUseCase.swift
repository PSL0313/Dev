//
//  CreateFeedUseCase.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//

// MARK: - 피드 배치 업로드를 수행하는 UseCase
final class CreateFeedUseCase: CreateFeedUseCaseProtocol, @unchecked Sendable {
    private let repository: MediaStorageRepositoryProtocol

    init(repository: MediaStorageRepositoryProtocol) {
        self.repository = repository
    }

    func execute(draft: FeedUploadDraft) async throws -> FeedUploadResultEntity {
        try await repository.createFeed(draft)
    }
}
