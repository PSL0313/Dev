//
//  Member.swift
//  Flover9
//
//  Created by 박선린 on 4/23/26.
//


enum Member: String, Codable, CaseIterable {
    case songhayoung = "SongHaYoung"
    case parkjiwon = "ParkJiWon"
    case leechaeyoung = "LeeChaeYoung"
    case leenakyung = "LeeNaKyung"
    case baekjiheon = "BaekJiHeon"
    case group = "Group"
    
    var name: String {
        switch self {
        case .songhayoung:
            return "송하영"
        case .parkjiwon:
            return "박지원"
        case .leechaeyoung:
            return "이채영"
        case .leenakyung:
            return "이나경"
        case .baekjiheon:
            return "백지헌"
        case .group:
            return "단체사진"
        }
    }
    var id: String {
        switch self {
        case .songhayoung:
            return "SongHaYoung"
        case .parkjiwon:
            return "ParkJiWon"
        case .leechaeyoung:
            return "LeeChaeYoung"
        case .leenakyung:
            return "LeeNaKyung"
        case .baekjiheon:
            return "BaekJiHeon"
        case .group:
            return "Group"
        }
    }
}