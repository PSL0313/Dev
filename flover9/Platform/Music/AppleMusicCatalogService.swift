//
//  AppleMusicCatalogService.swift
//  flover9
//
//  Created by 박선린 on 8/16/26.
//
import MusicKit

struct AppleMusicCatalogService {
    // 아이디로 애플뮤직에 있는 앨범을 가져오는 함수
    func fetchAlbum(id: String) async throws -> Album {
        let musicItemID = MusicItemID(id)

        var request = MusicCatalogResourceRequest<Album>(
            matching: \.id,
            equalTo: musicItemID
        )

        // 기본 앨범 정보 외에 함께 가져올 관계 데이터
        request.properties = [
            .artists,
            .tracks
        ]

        let response = try await request.response()

        guard let album = response.items.first else {
            throw AppleMusicCatalogError.albumNotFound
        }

        return album
    }
    
    // 엔터티를 받아서 앨범을 가져오는 함수
    func fetchAlbum(from albumEntity: MusicAlbumEntity) async throws -> Album {
        guard let id = albumEntity.platformIDs.appleMusic else {
            throw AppleMusicCatalogError.platformIDNotFound
        }
        let musicItemID = MusicItemID(id)

        var request = MusicCatalogResourceRequest<Album>(
            matching: \.id,
            equalTo: musicItemID
        )

        // 기본 앨범 정보 외에 함께 가져올 관계 데이터
        request.properties = [
            .artists,
            .tracks
        ]

        let response = try await request.response()

        guard let album = response.items.first else {
            throw AppleMusicCatalogError.albumNotFound
        }

        print("요청 ID:", id)
        print("응답 ID:", album.id.rawValue)
        print("재생 정보:", album.playParameters as Any)
        
        return album
    }
    
    // 아이디 배열을 받아서 앨범들을 가져오는 함수
    func fetchAlbums(ids: [String]) async throws -> [Album] {
        var albums: [Album] = []
        
        for id in ids {
            let musicItemID = MusicItemID(id)
            
            var request = MusicCatalogResourceRequest<Album>(
                matching: \.id,
                equalTo: musicItemID
            )
            
            // 기본 앨범 정보 외에 함께 가져올 관계 데이터
            request.properties = [
                .artists,
                .tracks
            ]
            
            let response = try await request.response()
            
            guard let album = response.items.first else {
                throw AppleMusicCatalogError.albumNotFound
            }
            
            albums.append(album)
        }
        return albums
    }
    
    func fetchAlbums(from albumEntities: [MusicAlbumEntity]) async throws -> [Album] {
        let ids = appleMusicIDs(from: albumEntities)
        guard !ids.isEmpty else {
            throw AppleMusicCatalogError.platformIDNotFound
        }
        
        var albums: [Album] = []
        
        for id in ids {
            let musicItemID = MusicItemID(id)
            
            var request = MusicCatalogResourceRequest<Album>(
                matching: \.id,
                equalTo: musicItemID
            )
            
            // 기본 앨범 정보 외에 함께 가져올 관계 데이터
            request.properties = [
                .artists,
                .tracks
            ]
            
            let response = try await request.response()
            
            guard let album = response.items.first else {
                throw AppleMusicCatalogError.albumNotFound
            }
            
            albums.append(album)
        }
        return albums
    }
}

extension AppleMusicCatalogService {
    /// 앨범 Entity 배열에서 중복되지 않은 Apple Music 앨범 ID를 추출합니다.
    private func appleMusicIDs(
        from albumEntities: [MusicAlbumEntity]
    ) -> [String] {
        var insertedIDs = Set<String>()

        return albumEntities.compactMap { albumEntity in
            guard let appleMusicID =
                    albumEntity.platformIDs.appleMusic,
                  insertedIDs.insert(appleMusicID).inserted else {
                return nil
            }

            return appleMusicID
        }
    }
}
