//
//  WallpaperAdminListViewController.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import SnapKit
import UIKit

// 관리 가능한 시리즈 목록과 생성·수정·삭제 화면을 구성하고 사용자 동작을 연결합니다.
final class WallpaperAdminListViewController: UITableViewController {
    private let viewModel: WallpaperAdminListViewModel
    var onEditSeries: ((WallpaperSeriesEntity?) -> Void)?
    init(manage: ManageWallpapersUseCase) {
        viewModel = .init(manage: manage)
        super.init(style: .insetGrouped)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "배경화면 시리즈"
        overrideUserInterfaceStyle = .dark
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add, primaryAction: UIAction { [weak self] _ in self?.onEditSeries?(nil) })
        refreshControl = UIRefreshControl()
        refreshControl?.addAction(UIAction { [weak self] _ in self?.viewModel.load() }, for: .valueChanged)
        viewModel.onChange = { [weak self] in self?.render() }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }
    private func render() {
        tableView.reloadData()
        if !viewModel.isLoading { refreshControl?.endRefreshing() }
        navigationItem.rightBarButtonItem?.isEnabled = !viewModel.isLoading && viewModel.canCreate
        wallpaperListStatus(
            loading: viewModel.isLoading, error: viewModel.error, empty: viewModel.seriesItems.isEmpty,
            retry: { [weak self] in self?.viewModel.load() })
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.seriesItems.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let item = viewModel.seriesItems[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text =
            "\(item.creatorName) · \(item.category.title) · \(item.wallpaperCount)개 · \(item.isPublished ? "공개" : "초안")"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !viewModel.isLoading else { return }
        onEditSeries?(viewModel.seriesItems[indexPath.row])
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration?
    {
        guard !viewModel.isLoading else { return nil }
        let item = viewModel.seriesItems[indexPath.row]
        return .init(actions: [
            UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, done in
                self?.confirmWallpaperDeletion(item.title) { self?.viewModel.delete(series: item) }
                done(true)
            }
        ])
    }
}
