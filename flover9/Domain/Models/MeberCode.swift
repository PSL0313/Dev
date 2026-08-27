//
//  MeberCode.swift
//  flover9
//
//  Created by 박선린 on 8/8/26.
//

nonisolated enum MemberCode: String, Codable, Sendable, Equatable, Hashable {
    case hayoung
    case jiwon
    case chaeyoung
    case nagyung
    case jiheon
}

extension MemberCode {
    func getDisplayName(isFull: Bool = true) -> String {
        switch isFull {
        case true:
            switch self {
            case .hayoung:
                return "송하영"
            case .jiwon:
                return "박지원"
            case .chaeyoung:
                return "이채영"
            case .nagyung:
                return "이나경"
            case .jiheon:
                return "백지헌"
            }
        case false:
            switch self {
            case .hayoung:
                return "하영"
            case .jiwon:
                return "지원"
            case .chaeyoung:
                return "채영"
            case .nagyung:
                return "나경"
            case .jiheon:
                return "지헌"
            }
        }
    }
}
