//
//  MemberProfile.swift
//  Flover9
//
//  Created by 박선린 on 4/23/26.
//


import Foundation

struct MemberProfile: Identifiable, Codable {
    let id: String
    let koreanName: String
    let englishName: String
    let birthday: String
    let instagramUrl: String
    let frommUrl: String
    let profileImageUrl: String
    
    init(id: String, koreanName: String, englishName: String, birthday: String, instagramUrl: String, frommUrl: String , profileImageUrl: String) {
        self.id = id
        self.koreanName = koreanName
        self.englishName = englishName
        self.profileImageUrl = profileImageUrl
        self.birthday = birthday
        self.frommUrl = frommUrl
        self.instagramUrl = instagramUrl
    }
}