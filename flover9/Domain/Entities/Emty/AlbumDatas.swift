//
//  AlbumDatas.swift
//  Flover9
//
//  Created by 박선린 on 4/23/26.
//
import UIKit

struct AlbumDatas: Identifiable, Codable {
    let id: String
    let singerid: [String]
    let withArtists: [String]?
    let albumType: AlbumType
    let albumName: String
    let albumImageUrl: String           
    let releaseDate: String
    
    let albumDescription: Array<String>?
    
    let musicTitleTrack: [String]
    let musicTracks: [String]
    var appleMusicAlbumID: String? = nil
    var appleMusicTrackIDs: [String]? = nil
    let youtubeUrl: String?
    let youtubeMusicUrl: String?
}
