//
//  UpdateNickname.swift
//  flover9
//
//  Created by 박선린 on 10/6/26.
//

import Foundation

@MainActor
protocol UpdateProfileUsecaseProtocol: Sendable {
    func update(nickname: String) async throws 
    
    func isAvailableNickname(_ nickname: String) async throws -> (String, Bool)
}
