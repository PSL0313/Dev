//
//  AdminListViewController.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

import UIKit
import Kingfisher

final class AdminListViewController: UITableViewController, UISearchBarDelegate {
    // MARK: - Properties
    private let viewModel: AdminListViewModel
    private let isSelectingEvent: Bool
    var onManageEvents: (() -> Void)?
    private let searchController = UISearchController(searchResultsController: nil)

    init(viewModel: AdminListViewModel, isSelectingEvent: Bool = false) {
        self.viewModel = viewModel
        self.isSelectingEvent = isSelectingEvent
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = isSelectingEvent ? "행사 선택" : viewModel.category.title
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "item")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 92
        tableView.keyboardDismissMode = .onDrag

        searchController.searchBar.placeholder = "제목 검색"
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            primaryAction: UIAction { [weak self] _ in self?.viewModel.create() }
        )
        navigationItem.rightBarButtonItem?.accessibilityLabel = "새 항목 추가"
        if viewModel.category == .schedules {
            navigationItem.rightBarButtonItems?.append(UIBarButtonItem(
                title: "행사",
                primaryAction: UIAction { [weak self] _ in self?.onManageEvents?() }
            ))
        }

        refreshControl = UIRefreshControl()
        refreshControl?.addAction(UIAction { [weak self] _ in
            self?.viewModel.reload()
        }, for: .valueChanged)
        viewModel.onChange = { [weak self] in self?.render() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reload()
    }

    // MARK: - 검색은 키보드의 검색 버튼을 누를 때 서버에 요청
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.reload(query: searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.reload(query: "")
    }

    private func render() {
        if !viewModel.isLoading { refreshControl?.endRefreshing() }
        navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = !viewModel.isLoading }
        tableView.reloadData()

        if viewModel.items.isEmpty {
            var configuration = UIContentUnavailableConfiguration.empty()
            configuration.image = UIImage(systemName: viewModel.isLoading ? "hourglass" : "tray")
            configuration.text = viewModel.isLoading ? "목록을 불러오고 있어요" : "표시할 항목이 없어요"
            configuration.secondaryText = viewModel.errorMessage ?? "새 항목을 추가하거나 다른 제목으로 검색해 보세요."
            configuration.button.title = viewModel.errorMessage == nil ? "새로고침" : "다시 시도"
            // 빈 목록이나 오류 상태에서 다시 조회합니다.
            configuration.buttonProperties.primaryAction = UIAction { [weak self] _ in
                self?.viewModel.reload()
            }
            contentUnavailableConfiguration = configuration
        } else {
            contentUnavailableConfiguration = nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count + (viewModel.canLoadMore && !viewModel.items.isEmpty ? 1 : 0)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        isSelectingEvent ? "이 일정이 속할 행사를 골라 주세요" : "\(viewModel.items.count)개 불러옴"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath)
        var content = cell.defaultContentConfiguration()
        cell.accessoryType = .none

        guard viewModel.items.indices.contains(indexPath.row) else {
            content.text = viewModel.isLoading ? "불러오는 중…" : "더 불러오기"
            content.secondaryText = viewModel.errorMessage
            content.textProperties.color = AdminStyle.accent
            cell.contentConfiguration = content
            return cell
        }

        let item = viewModel.items[indexPath.row]
        content.text = item.title
        content.textProperties.numberOfLines = 2
        content.secondaryTextProperties.numberOfLines = 2
        content.imageProperties.tintColor = AdminStyle.accent
        switch item {
        case .feed(let feed):
            content.image = UIImage(systemName: feed.displayType == .shorts ? "play.rectangle" : "photo.stack")
            content.secondaryText = "\(feed.source) · 미디어 \(feed.contentCount)개\n\(feed.captureDate.formatted(date: .abbreviated, time: .omitted))"
        case .schedule(let schedule):
            content.image = UIImage(systemName: "calendar")
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.timeZone = TimeZone(identifier: schedule.timeZone)
            formatter.dateFormat = "M월 d일 (E) HH:mm"
            content.secondaryText = "\(formatter.string(from: schedule.startAt)) · \(schedule.status.statusName())\n\(schedule.venueName ?? "장소 미정")"
        case .event(let event):
            content.image = UIImage(systemName: "square.stack.3d.up")
            content.secondaryText = "\(event.type.categoryName()) · \(event.venueName ?? "장소 미정")"
        }
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if viewModel.items.indices.contains(indexPath.row) {
            viewModel.select(indexPath.row)
        } else {
            viewModel.loadMore()
        }
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !isSelectingEvent, viewModel.items.indices.contains(indexPath.row) else { return nil }
        let action = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            self?.viewModel.requestDeletion(indexPath.row)
            completion(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
