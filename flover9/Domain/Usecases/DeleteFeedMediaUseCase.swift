//
//  DeleteFeedMediaUseCase.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//
import Foundation

// MARK: - 피드 미디어와 연결된 R2 객체를 삭제하는 UseCase
final class DeleteFeedMediaUseCase: DeleteFeedMediaUseCaseProtocol, @unchecked Sendable {
    private let repository: MediaStorageRepositoryProtocol

    init(repository: MediaStorageRepositoryProtocol) {
        self.repository = repository
    }

    func execute(mediaID: UUID) async throws {
        try await repository.deleteFeedMedia(mediaID: mediaID)
    }
}
