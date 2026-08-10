//
//  FeedMemberEntity.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//
import Foundation

struct FeedMemberEntity: Identifiable, Equatable {
    let id: UUID
    let feedId: UUID
    let memberCode: MemberCode
}
