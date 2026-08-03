//
//  PersonName.swift
//  flover9
//
//  Created by 박선린 on 7/31/26.
//


// MARK: - Apple에서 전달받은 사용자 이름
struct PersonName: Sendable, Equatable {
    let givenName: String?    // 이름
    let familyName: String?   // 성
}