//
//  HomeTabSectionHeaderType.swift
//  flover9
//
//  Created by 박선린 on 8/14/26.
//


enum HomeTabSectionHeaderType {
    case member
    case upComingSchedule
    case albums
    case otherAlbums
}

extension HomeTabSectionHeaderType {
    func title() -> String {
        switch self {
        case .member: return ""
        case .upComingSchedule: return "Upcoming Schedule"
        case .albums: return "Albums"
        case .otherAlbums: return "Other Albums"
        }
    }
}
