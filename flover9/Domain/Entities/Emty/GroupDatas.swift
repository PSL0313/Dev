//
//  GroupDatas.swift
//  Flover9
//
//  Created by 박선린 on 4/23/26.
//


struct GroupDatas: Identifiable, Codable {
    let id: String
    let groupName: String               // 그룹 이름
    let groupProfileImageUrl: String    // 단체 사진 이미지 URL
    let leaderid: String                // 리터 ID
    let membersid: [String]             // json으로 저장한 멤버 아이디
    let debutDate: String               // 데뷔일
    let agency: String                  // 소속사
    
    let albums: [AlbumDatas]            // 앨범
    let others: [AlbumDatas]              // ost
}