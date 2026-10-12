//
//  WallpaperFilterViewController.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import UIKit

// 멤버·카테고리·제작자·시리즈 검색 조건 화면을 구성하고 사용자 동작을 연결합니다.
final class WallpaperFilterViewController: UITableViewController {
    private var filter: WallpaperSearchFilter
    private let options: WallpaperFilterOptions
    var onApply: ((WallpaperSearchFilter) -> Void)?
    init(filter: WallpaperSearchFilter, options: WallpaperFilterOptions) {
        self.filter = filter
        self.options = options
        super.init(style: .insetGrouped)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "검색 필터"
        overrideUserInterfaceStyle = .dark
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "취소", primaryAction: UIAction { [weak self] _ in self?.dismiss(animated: true) })
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "적용",
            primaryAction: UIAction { [weak self] _ in
                guard let self else { return }
                onApply?(filter)
                dismiss(animated: true)
            })
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 5 }
    private func current(_ row: Int) -> String? {
        switch row {
        case 0: filter.category?.rawValue
        case 1: filter.memberCode
        case 2: filter.creatorID?.uuidString
        case 3: filter.seriesID?.uuidString
        default: nil
        }
    }
    private func choices(_ row: Int) -> [WallpaperChoice] {
        switch row {
        case 0: WallpaperCategory.allCases.map { .init(id: $0.rawValue, title: $0.title) }
        case 1: options.members
        case 2: options.creators
        case 3: options.series
        default: []
        }
    }
    private let labels = ["카테고리", "멤버", "크리에이터", "시리즈", "필터 초기화"]
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = labels[indexPath.row]
        if indexPath.row < 4 {
            cell.detailTextLabel?.text = choices(indexPath.row).first { $0.id == current(indexPath.row) }?.title ?? "전체"
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if row == 4 {
            let query = filter.query
            filter = WallpaperSearchFilter()
            filter.query = query
            tableView.reloadData()
            return
        }
        let picker = WallpaperChoicePickerViewController(
            title: labels[row], options: [.init(id: "", title: "전체")] + choices(row), selected: [current(row) ?? ""])
        picker.onSelect = { [weak self] selected in
            guard let self else { return }
            let value = selected.first.flatMap { $0.isEmpty ? nil : $0 }
            switch row {
            case 0: filter.category = value.flatMap(WallpaperCategory.init)
            case 1: filter.memberCode = value
            case 2: filter.creatorID = value.flatMap(UUID.init)
            case 3: filter.seriesID = value.flatMap(UUID.init)
            default: break
            }
            tableView.reloadData()
        }
        navigationController?.pushViewController(picker, animated: true)
    }
}
