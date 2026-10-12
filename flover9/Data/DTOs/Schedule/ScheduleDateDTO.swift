//
//  ScheduleDateDTO.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//
import Foundation

struct ScheduleDateDTO: Decodable {
    let startAt: Date

    enum CodingKeys: String, CodingKey {
        case startAt = "start_at"
    }
}
