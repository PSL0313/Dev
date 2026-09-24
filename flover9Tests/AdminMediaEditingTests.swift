import XCTest
import UIKit
@testable import flover9

@MainActor
final class AdminMediaEditingTests: XCTestCase {
    func testEditorDeletionRequiresConfirmation() async throws {
        let useCase = MediaEditorUseCaseStub()
        let model = AdminEditorViewModel(mode: .editFeed(useCase.feed), useCase: useCase, logger: MediaEditorLoggerStub())
        let loaded = expectation(description: "권한 확인")
        model.onState = { state in if case .editing = state { loaded.fulfill() } }
        model.checkAccess()
        await fulfillment(of: [loaded], timeout: 3)
        var requested = false
        model.onRoute = { route in if case .confirmDelete = route { requested = true } }
        model.requestDeletion()
        XCTAssertTrue(requested)
        XCTAssertEqual(useCase.deleteCount, 0)
        let deleted = expectation(description: "확인 후 삭제")
        model.onRoute = { route in if case .deleted = route { deleted.fulfill() } }
        model.delete()
        model.delete() // 중복 탭 방지
        await fulfillment(of: [deleted], timeout: 3)
        XCTAssertEqual(useCase.deleteCount, 1)
    }

    func testExistingFeedSavesNewFilesWithOriginalMedia() async throws {
        let useCase = MediaEditorUseCaseStub()
        let model = AdminEditorViewModel(mode: .editFeed(useCase.feed), useCase: useCase, logger: MediaEditorLoggerStub())
        let loaded = expectation(description: "기존 사진")
        model.onState = { state in if case .editing = state { loaded.fulfill() } }
        model.checkAccess()
        await fulfillment(of: [loaded], timeout: 3)
        let file = UploadMediaFile(fileURL: URL(fileURLWithPath: "/tmp/new.jpg"), contentType: .jpeg, fileSizeBytes: 100, sortOrder: 0)
        try model.appendFiles([file])
        XCTAssertEqual(model.previewItems.count, 3)
        let saved = expectation(description: "추가 사진 저장")
        model.onRoute = { route in if case .saved = route { saved.fulfill() } }
        model.save()
        await fulfillment(of: [saved], timeout: 3)
        XCTAssertEqual(useCase.savedDraft?.media.count, 1)
        XCTAssertEqual(useCase.savedDraft?.mediaEdit.existing.count, 2)
    }
    func testRemovalIsDeferredAndCanBeUndone() async throws {
        let useCase = MediaEditorUseCaseStub()
        let model = AdminEditorViewModel(mode: .editFeed(useCase.feed), useCase: useCase, logger: MediaEditorLoggerStub())
        let loaded = expectation(description: "미디어 로딩")
        model.onState = { state in if case .editing = state { loaded.fulfill() } }
        model.checkAccess()
        await fulfillment(of: [loaded], timeout: 3)
        let mediaID = try XCTUnwrap(model.mediaEdit.existing.first?.id)
        model.toggleRemoval(mediaID)
        XCTAssertTrue(model.mediaEdit.removedIDs.contains(mediaID))
        XCTAssertEqual(useCase.saveCount, 0)
        XCTAssertEqual(model.previewItems.count, 2)
        model.toggleRemoval(mediaID)
        XCTAssertFalse(model.mediaEdit.removedIDs.contains(mediaID))
        XCTAssertEqual(useCase.saveCount, 0)
        model.toggleRemoval(mediaID)
        let saved = expectation(description: "저장")
        model.onState = nil
        model.onRoute = { route in if case .saved = route { saved.fulfill() } }
        model.save()
        await fulfillment(of: [saved], timeout: 3)
        XCTAssertEqual(useCase.saveCount, 1)
        XCTAssertEqual(useCase.savedDraft?.mediaEdit.removedIDs, [mediaID])
    }

    func testPhotoSelectionsAppendAndRenumber() throws {
        let useCase = MediaEditorUseCaseStub()
        let model = AdminEditorViewModel(mode: .newFeed, useCase: useCase, logger: MediaEditorLoggerStub())
        let file1 = UploadMediaFile(fileURL: URL(fileURLWithPath: "/tmp/one.jpg"), contentType: .jpeg, fileSizeBytes: 100, sortOrder: 0)
        let file2 = UploadMediaFile(fileURL: URL(fileURLWithPath: "/tmp/two.jpg"), contentType: .jpeg, fileSizeBytes: 100, sortOrder: 0)
        try model.appendFiles([file1])
        try model.appendFiles([file2])
        XCTAssertEqual(model.selectedFiles.map(\.sortOrder), [0,1])
        model.toggleRemoval(try XCTUnwrap(model.previewItems.first?.id))
        XCTAssertEqual(model.selectedFiles.map(\.sortOrder), [0])
        XCTAssertEqual(model.selectedFiles.first?.fileURL, file2.fileURL)
        XCTAssertEqual(useCase.saveCount, 0)
    }

    func testEditorLayoutSnapshot() async throws {
        let useCase = MediaEditorUseCaseStub()
        let model = AdminEditorViewModel(mode: .editFeed(useCase.feed), useCase: useCase, logger: MediaEditorLoggerStub())
        let editor = AdminEditorViewController(viewModel: model)
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: 0,y: 0,width: 393,height: 852)
        window.windowLevel = .alert + 1
        let navigationController = UINavigationController(rootViewController: editor)
        AdminStyle.configureNavigationBar(navigationController.navigationBar)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        editor.loadViewIfNeeded()
        window.layoutIfNeeded()
        let loaded = expectation(description: "레이아웃 준비")
        let renderState = model.onState
        model.onState = { state in
            renderState?(state)
            if case .editing = state { loaded.fulfill() }
        }
        model.checkAccess()
        await fulfillment(of: [loaded], timeout: 3)
        model.onState = renderState
        // 공개 구성 함수를 통해 미디어 카드의 실제 레이아웃을 검증합니다.
        let strip = try XCTUnwrap(find(AdminMediaStripView.self, in: editor.view))
        model.toggleRemoval(model.previewItems[0].id)
        strip.isHidden = false
        window.layoutIfNeeded()
        editor.view.layoutIfNeeded()
        try await Task.sleep(for: .milliseconds(150)) // 로컬 이미지 디코딩 완료 후 캡처
        let snapshot = UIGraphicsImageRenderer(bounds: window.bounds).image { context in window.layer.render(in: context.cgContext) }
        let attachment = XCTAttachment(image: snapshot)
        attachment.name = "관리자 피드 수정 - 삭제 예약"
        attachment.lifetime = .keepAlways
        add(attachment)
        let path = FileManager.default.temporaryDirectory.appendingPathComponent("admin-feed-editor.png")
        try snapshot.pngData()?.write(to: path)
        print("ADMIN_SCREENSHOT=\(path.path)")
        XCTAssertGreaterThan(strip.bounds.height, 100)
        window.isHidden = true
    }

    private func find<T: UIView>(_ type: T.Type, in view: UIView) -> T? {
        if let match = view as? T { return match }
        return view.subviews.compactMap { find(type, in: $0) }.first
    }
}

@MainActor
private final class MediaEditorUseCaseStub: AdminUseCaseProtocol {
    private(set) var saveCount = 0
    private(set) var deleteCount = 0
    private(set) var savedDraft: AdminFeedDraft?
    let feed = FeedEntity(id: UUID(), title: "테스트 피드", sourceName: "공식 계정", description: "편집 화면 확인", captureDate: .now, source: "instagram", permalink: "https://example.com/feed", thumbnailURL: nil, displayType: .feed, contentCount: 2)
    func endEditing(id: UUID) {}
    func authorize() async throws -> UserProfile {
        UserProfile(id: UUID(),nickname: "관리자",role: .manager,profileImageURL: nil,createdAt: .now,updatedAt: .now)
    }
    func fetchMedia(category: AdminCategory, id: UUID) async throws -> [AdminMediaItem] {
        try (0..<2).map { index in
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("admin-fixture-\(index).jpg")
            let image = UIGraphicsImageRenderer(size: CGSize(width: 280,height: 356)).image { context in
                (index == 0 ? UIColor.systemMint : UIColor.systemIndigo).setFill()
                context.fill(CGRect(x: 0,y: 0,width: 280,height: 356))
                "MEDIA \(index + 1)".draw(at: CGPoint(x: 50,y: 160), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 30), .foregroundColor: UIColor.white])
            }
            try image.jpegData(compressionQuality: 0.8)?.write(to: url)
            return AdminMediaItem(id: UUID(),url: url,contentType: .jpeg,sortOrder: index)
        }
    }
    func fetchItems(category: AdminCategory, offset: Int, query: String) async throws -> [AdminContent] { [.feed(feed)] }
    func saveFeed(_ draft: AdminFeedDraft, isNew: Bool) async throws { saveCount += 1; savedDraft = draft }
    func saveSchedule(_ draft: AdminScheduleDraft, isNew: Bool) async throws {}
    func saveEvent(_ draft: AdminEventDraft, isNew: Bool) async throws {}
    func delete(_ item: AdminContent) async throws -> Bool { deleteCount += 1; return true }
}

private struct MediaEditorLoggerStub: ErrorLogging {
    func record(_ error: AdminError) async {}
    func record(_ error: AuthError) async {}
    func record(_ error: ProfileError) async {}
    func record(_ error: MediaUploadError) async {}
    func record(_ error: ScheduleError) async {}
}
