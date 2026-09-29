//
//  WallpaperLayoutTests.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import UIKit
import XCTest
@testable import flover9

/// Uses bundled artwork, never production catalog writes or network images.
// 테스트 카탈로그로 주요 Wallpaper 화면을 렌더링하고 캡처합니다.
@MainActor final class WallpaperLayoutTests: XCTestCase {
    func testWallpaperScreensRenderWithCatalogData() async throws {
        let repository = WallpaperLayoutRepository()
        let image = try XCTUnwrap(UIImage(named: "flover9Banner"))
        try await ImageCache.default.store(image, forKey: repository.imageURL.absoluteString, toDisk: false)
        let browse = BrowseWallpapersUseCase(repository: repository)
        let home = WallpaperHomeViewController(viewModel: .init(browse: browse))
        let list = WallpaperSeriesListViewController(viewModel: .init(browse: browse))
        let detail = WallpaperSeriesDetailViewController(series: repository.seriesItems[0], browse: browse)
        let search = WallpaperSearchViewController(viewModel: .init(browse: browse))
        let preview = WallpaperPreviewViewController(
            items: repository.items, index: 1, download: .init(repository: WallpaperDownloadRepository()),
            favorites: .init(defaults: UserDefaults(suiteName: "wallpaper.layout.test")!))
        for (name, controller) in [
            ("home", home as UIViewController), ("series", list), ("detail", detail), ("search", search),
            ("preview", preview),
        ] {
            let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
            let window = UIWindow(windowScene: scene)
            let navigation = UINavigationController(rootViewController: controller)
            WallpaperStyle.navigation(navigation)
            if name == "home" || name == "series" {
                let tabs = UITabBarController()
                tabs.overrideUserInterfaceStyle = .dark
                navigation.tabBarItem = .init(title: "홈", image: UIImage(systemName: "house"), selectedImage: nil)
                let other = ["시리즈", "즐겨찾기", "설정"].enumerated().map { index, title -> UIViewController in
                    let vc = UIViewController()
                    vc.tabBarItem = .init(
                        title: title, image: UIImage(systemName: ["square.grid.2x2", "heart", "gearshape"][index]),
                        selectedImage: nil)
                    return vc
                }
                tabs.viewControllers = [navigation] + other
                tabs.tabBar.tintColor = .white
                window.rootViewController = tabs
            } else {
                window.rootViewController = navigation
            }
            window.makeKeyAndVisible()
            // Allows asynchronous view-model and image-cache delivery to reach the view.
            try await Task.sleep(for: .milliseconds(300))
            window.layoutIfNeeded()
            controller.view.layoutIfNeeded()
            if let collection = controller as? UICollectionViewController {
                XCTAssertGreaterThan(collection.collectionView.numberOfItems(inSection: 0), 0, name)
            }
            XCTAssertGreaterThan(controller.view.bounds.width, 0)
            let rendered = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            }
            let attachment = XCTAttachment(image: rendered)
            attachment.name = "wallpaper-\(name)"
            attachment.lifetime = .keepAlways
            add(attachment)
            window.isHidden = true
        }
    }
}
