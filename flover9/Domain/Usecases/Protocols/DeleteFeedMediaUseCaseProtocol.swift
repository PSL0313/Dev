//
//  DeleteFeedMediaUseCaseProtocol.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//
import Foundation

// MARK: - 피드 미디어 삭제 기능 규약
protocol DeleteFeedMediaUseCaseProtocol: Sendable {
    func execute(mediaID: UUID) async throws
}
