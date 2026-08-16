//
//  AppleMusicCatalogError.swift
//  flover9
//
//  Created by 박선린 on 8/16/26.
//



enum AppleMusicCatalogError: Error {
    case albumNotFound
    case platformIDNotFound
}

extension AppleMusicCatalogError {
    var message: String {
        switch self {
        case .albumNotFound:
            return "album not found"
        case .platformIDNotFound:
            return "platform id not found"
        }
    }
}
