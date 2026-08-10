//
//  MemberEntity.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//
import Foundation

struct MemberEntity: Identifiable, Equatable {
    var id: String { code }

    let code: String
    let displayName: String
    let sortOrder: Int
    let isActive: Bool
    let createdAt: Date
}
