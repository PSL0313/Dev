//
//  FeedRepositoryProtocol.swift
//  Flover9
//
//  Created by 박선린 on 5/12/26.
//

import Foundation

protocol FeedRepositoryProtocol {
    func excute(limit: Int) async throws -> [FeedEntity]

}
