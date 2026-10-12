//
//  WallpaperAdminItemsViewController.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import SnapKit
import UIKit

// 시리즈에 속한 배경화면 목록과 추가·수정·삭제 화면을 구성하고 사용자 동작을 연결합니다.
final class WallpaperAdminItemsViewController: UITableViewController {
    private let viewModel: WallpaperAdminListViewModel
    var onEdit: ((WallpaperEntity?) -> Void)?
    init(series: WallpaperSeriesEntity, manage: ManageWallpapersUseCase) {
        viewModel = .init(manage: manage, series: series)
        super.init(style: .insetGrouped)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.series?.title
        overrideUserInterfaceStyle = .dark
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add, primaryAction: UIAction { [weak self] _ in self?.onEdit?(nil) })
        refreshControl = UIRefreshControl()
        refreshControl?.addAction(UIAction { [weak self] _ in self?.viewModel.load() }, for: .valueChanged)
        viewModel.onChange = { [weak self] in
            guard let self else { return }
            tableView.reloadData()
            if !viewModel.isLoading { refreshControl?.endRefreshing() }
            navigationItem.rightBarButtonItem?.isEnabled = !viewModel.isLoading
            wallpaperListStatus(
                loading: viewModel.isLoading, error: viewModel.error, empty: viewModel.wallpapers.isEmpty,
                retry: { [weak self] in self?.viewModel.load() })
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.wallpapers.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let item = viewModel.wallpapers[indexPath.row]
        cell.textLabel?.text = item.displayLabel
        cell.detailTextLabel?.text = "순서 \(item.sortOrder) · 연결된 멤버 \(item.memberCodes.count)명"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !viewModel.isLoading else { return }
        onEdit?(viewModel.wallpapers[indexPath.row])
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration?
    {
        guard !viewModel.isLoading else { return nil }
        let item = viewModel.wallpapers[indexPath.row]
        return .init(actions: [
            UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, done in
                self?.confirmWallpaperDeletion(item.displayLabel) { self?.viewModel.delete(wallpaper: item) }
                done(true)
            }
        ])
    }
}
