//
//  WallpaperCoordinator.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import UIKit

// Wallpaper 전용 탭과 상세·검색·미리보기·관리 화면 사이의 이동을 연결합니다.
final class WallpaperCoordinator: BaseCoordinator {
    var rootViewController: UIViewController { service }
    var onFinish: (() -> Void)?
    private let container: AppDIContainer
    private let service = UITabBarController()
    private let homeNavigation = UINavigationController()
    private let seriesNavigation = UINavigationController()
    private let favoritesNavigation = UINavigationController()
    private let settingsNavigation = UINavigationController()
    
    init(container: AppDIContainer) {
        self.container = container
    }
    override func start() {
        let home = WallpaperHomeViewController(viewModel: container.makeWallpaperHomeViewModel())
        let series = WallpaperSeriesListViewController(
            viewModel: .init(browse: container.makeBrowseWallpapersUseCase()))
        home.onSeries = { [weak self] in self?.showSeries($0, in: self?.homeNavigation) }
        series.onSeries = { [weak self] in self?.showSeries($0, in: self?.seriesNavigation) }
        home.onSearch = { [weak self] in self?.showSearch(in: self?.homeNavigation) }
        series.onSearch = { [weak self] in self?.showSearch(in: self?.seriesNavigation) }
        home.onAllSeries = { [weak self, weak series] category in
            self?.service.selectedIndex = 1
            self?.seriesNavigation.popToRootViewController(animated: false)
            series?.selectCategory(category)
        }
        home.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.down"), primaryAction: UIAction { [weak self] _ in self?.close() })
        home.navigationItem.leftBarButtonItem?.accessibilityLabel = "flover9 홈으로"
        let favorites = WallpaperFavoritesViewController(store: container.wallpaperFavorites)
        favorites.onWallpaper = { [weak self] items, index in
            self?.showWallpaper(items, index: index, in: self?.favoritesNavigation)
        }
        let settings = WallpaperSettingsViewController()
        settings.onManage = { [weak self] in self?.showManagement() }
        settings.onClose = { [weak self] in self?.close() }
        Task { [weak self, weak settings] in
            guard let self else { return }
            settings?.canManage = await container.canManageWallpapers()
        }
        let roots: [(UINavigationController, UIViewController, String, String)] = [
            (homeNavigation, home, "홈", "house"),
            (seriesNavigation, series, "시리즈", "square.grid.2x2"),
            (favoritesNavigation, favorites, "즐겨찾기", "heart"),
            (settingsNavigation, settings, "설정", "gearshape"),
        ]
        for (navigation, root, title, icon) in roots {
            navigation.setViewControllers([root], animated: false)
            navigation.tabBarItem = .init(title: title, image: UIImage(systemName: icon), selectedImage: nil)
            WallpaperStyle.navigation(navigation)
        }
        service.setViewControllers(roots.map { $0.0 }, animated: false)
        service.overrideUserInterfaceStyle = .dark
        service.modalPresentationStyle = .fullScreen
        service.modalTransitionStyle = .coverVertical
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        service.tabBar.standardAppearance = appearance
        service.tabBar.scrollEdgeAppearance = appearance
        service.tabBar.tintColor = .white
    }
    private func close() {
        service.dismiss(animated: true, completion: onFinish)
    }
    private func showManagement() {
        let controller = WallpaperAdminListViewController(manage: container.makeManageWallpapersUseCase())
        controller.onEditSeries = { [weak self] series in
            guard let self else { return }
            let editor = WallpaperSeriesEditorViewController(
                series: series, manage: container.makeManageWallpapersUseCase())
            editor.onWallpapers = { [weak self] in self?.showManagementItems($0) }
            settingsNavigation.pushViewController(editor, animated: true)
        }
        settingsNavigation.pushViewController(controller, animated: true)
    }
    private func showManagementItems(_ series: WallpaperSeriesEntity) {
        let controller = WallpaperAdminItemsViewController(
            series: series, manage: container.makeManageWallpapersUseCase())
        controller.onEdit = { [weak self] wallpaper in
            guard let self else { return }
            settingsNavigation.pushViewController(
                WallpaperItemEditorViewController(
                    series: series, wallpaper: wallpaper, manage: container.makeManageWallpapersUseCase()),
                animated: true)
        }
        settingsNavigation.pushViewController(controller, animated: true)
    }
    private func showSeries(_ series: WallpaperSeriesEntity, in navigation: UINavigationController?) {
        let detail = WallpaperSeriesDetailViewController(
            series: series, browse: container.makeBrowseWallpapersUseCase())
        detail.hidesBottomBarWhenPushed = true
        detail.onWallpaper = { [weak self, weak navigation] items, index in
            self?.showWallpaper(items, index: index, in: navigation)
        }
        navigation?.pushViewController(detail, animated: true)
    }
    private func showSearch(in navigation: UINavigationController?) {
        let search = WallpaperSearchViewController(viewModel: container.makeWallpaperSearchViewModel())
        search.onWallpaper = { [weak self, weak navigation] items, index in
            self?.showWallpaper(items, index: index, in: navigation)
        }
        navigation?.pushViewController(search, animated: true)
    }
    private func showWallpaper(_ items: [WallpaperEntity], index: Int, in navigation: UINavigationController?) {
        let preview = WallpaperPreviewViewController(
            items: items, index: index, download: container.makeDownloadWallpaperUseCase(),
            favorites: container.wallpaperFavorites)
        preview.hidesBottomBarWhenPushed = true
        navigation?.pushViewController(preview, animated: true)
    }
}
