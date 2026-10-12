//
//  WallpaperTests.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Supabase
import UIKit
import XCTest
@testable import flover9

// 업로드 재시도, 이미지 검증, 검색 응답 순서와 즐겨찾기 동작을 검증합니다.
@MainActor final class WallpaperTests: XCTestCase {
    func testTitlelessWallpaperAccepts50MBMockupAndRejectsLargerFile() async throws {
        let repository = WallpaperAdminStub()
        let useCase = ManageWallpapersUseCase(repository: repository)
        var draft = WallpaperDraft(id: UUID(), seriesID: UUID(), sortOrder: 0, memberCodes: [],
            mockup: .init(data: Data(count: 50 * 1024 * 1024), contentType: "image/png"))
        try await useCase.save(draft, isNew: false)
        XCTAssertEqual(repository.saves, 1)
        draft.mockup = .init(data: Data(count: 50 * 1024 * 1024 + 1), contentType: "image/png")
        do {
            try await useCase.save(draft, isNew: false)
            XCTFail("Oversized mockup must fail")
        } catch WallpaperError.validation {} 
        XCTAssertEqual(repository.saves, 1)
        let series = WallpaperSeriesDraft(id: UUID(), title: " ", creatorID: UUID(),
            category: .general, isFeatured: false, isPublished: false)
        do {
            try await useCase.save(series, isNew: true)
            XCTFail("Series title remains required")
        } catch WallpaperError.validation {}
        XCTAssertEqual(repository.saves, 1)
    }
    private func source() -> SupabaseWallpaperAdminRemoteDataSource {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [WallpaperHTTPStub.self]
        let session = URLSession(configuration: config)
        let client = SupabaseClient(
            supabaseURL: URL(string: "https://wallpaper.test")!, supabaseKey: "test-key",
            options: .init(global: .init(session: session)))
        return .init(client: client, authorization: AuthorizationRepositoryStub(), uploadSession: session)
    }
    func testMetadataEditMakesNoUploadRequests() async throws {
        var actions: [String] = []
        WallpaperHTTPStub.respond = { request in
            let body = try WallpaperHTTPStub.body(request)
            let action = body["action"] as? String ?? ""
            actions.append(action)
            XCTAssertEqual(action, "saveWallpaper")
            XCTAssertEqual(body["ticketIDs"] as? [String], [])
            XCTAssertEqual(body["expectedRevision"] as? Int, 7)
            return (200, ["saved": true])
        }
        let draft = WallpaperDraft(
            id: UUID(), seriesID: UUID(), sortOrder: 3, memberCodes: ["hayoung"], revision: 7)
        try await source().saveWallpaper(draft, isNew: false)
        XCTAssertEqual(actions, ["saveWallpaper"])
    }
    func testLostCommitResponseRetriesSameRequestWithoutUploadingAgain() async throws {
        var actions: [String] = []
        var putCount = 0
        var commitCount = 0
        var requests: [String] = []
        WallpaperHTTPStub.respond = { request in
            if request.httpMethod == "PUT" {
                putCount += 1
                return (200, [:])
            }
            let body = try WallpaperHTTPStub.body(request)
            let action = body["action"] as? String ?? ""
            actions.append(action)
            switch action {
            case "presign":
                return (
                    200,
                    [
                        "uploadURL": "https://upload.test/temporary/image.png",
                        "requiredHeaders": ["Content-Type": "image/png"],
                    ]
                )
            case "confirm": return (200, ["ticketID": body["ticketID"]!, "prepared": true])
            case "saveWallpaper":
                commitCount += 1
                requests.append(body["requestID"] as! String)
                return commitCount == 1 ? (500, ["error": "response lost"]) : (200, ["saved": true])
            default: throw URLError(.badServerResponse)
            }
        }
        let file = WallpaperImageFile(data: Data([137, 80, 78, 71, 13, 10, 26, 10]), contentType: "image/png")
        let draft = WallpaperDraft(
            id: UUID(), seriesID: UUID(), sortOrder: 0, memberCodes: [], original: file,
            revision: 1)
        let source = source()
        do {
            try await source.saveWallpaper(draft, isNew: false)
            XCTFail("Must report uncertainty")
        } catch WallpaperError.uncertain {} catch { XCTFail("Unexpected \(error)") }
        try await source.saveWallpaper(draft, isNew: false)
        XCTAssertEqual(putCount, 1)
        XCTAssertEqual(actions, ["presign", "confirm", "saveWallpaper", "saveWallpaper"])
        XCTAssertEqual(requests.first, requests.last)
    }
    func testNewWallpaperRequiresBothImagesBeforeRepository() async throws {
        let repository = WallpaperAdminStub()
        let useCase = ManageWallpapersUseCase(repository: repository)
        let draft = WallpaperDraft(id: UUID(), seriesID: UUID(), sortOrder: 0, memberCodes: [])
        do {
            try await useCase.save(draft, isNew: true)
            XCTFail("Missing images must fail")
        } catch {}
        XCTAssertEqual(repository.saves, 0)
    }
    func testSearchDiscardsLateResultFromPreviousFilter() async throws {
        let repository = WallpaperBrowseStub()
        let tested = WallpaperSearchViewModel(browse: .init(repository: repository))
        tested.filter.query = "old"
        tested.load()
        while repository.pending["old"] == nil { await Task.yield() }
        tested.filter.query = "new"
        tested.load()
        while repository.pending["new"] == nil { await Task.yield() }
        repository.pending.removeValue(forKey: "new")?.resume(returning: [Self.item(title: "New")])
        while tested.isLoading { await Task.yield() }
        repository.pending.removeValue(forKey: "old")?.resume(returning: [Self.item(title: "Old")])
        await Task.yield()
        XCTAssertEqual(tested.results.map(\.seriesTitle), ["New"])
    }
    func testPreviewCanLayoutEmptyAndNonzeroPage() throws {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        for items in [[], [Self.item(title: "One"), Self.item(title: "Two")]] {
            let view = WallpaperPreviewViewController(
                items: items, index: 1, download: .init(repository: WallpaperDownloadStub()),
                favorites: .init(defaults: defaults))
            view.loadViewIfNeeded()
            view.view.frame = CGRect(x: 0, y: 0, width: 393, height: 852)
            view.view.layoutIfNeeded()
            XCTAssertEqual(view.title, items.isEmpty ? "배경화면" : "2 / 2")
        }
    }
    func testDownloadRejectsNonHTTPSOriginal() async {
        var item = Self.item(title: "Image")
        item = WallpaperEntity(
            id: item.id, seriesID: item.seriesID, mockupURL: nil,
            originalURL: URL(string: "http://insecure.test/image.png"), sortOrder: 0, seriesTitle: "Test",
            category: .general, creatorID: UUID(), memberCodes: [])
        do {
            _ = try await DownloadWallpaperUseCase(repository: WallpaperDownloadStub()).execute(item)
            XCTFail("Must reject HTTP")
        } catch {}
    }
    func testFavoritesPersistAndToggle() {
        let name = UUID().uuidString
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let store = WallpaperFavoritesStore(defaults: defaults)
        let item = Self.item(title: "Favorite")
        store.toggle(item)
        XCTAssertTrue(WallpaperFavoritesStore(defaults: defaults).contains(item.id))
        store.toggle(item)
        XCTAssertFalse(store.contains(item.id))
    }
    static func item(title: String) -> WallpaperEntity {
        .init(
            id: UUID(), seriesID: UUID(), mockupURL: nil, originalURL: nil, sortOrder: 0,
            seriesTitle: title, category: .general, creatorID: UUID(), memberCodes: [])
    }
}
