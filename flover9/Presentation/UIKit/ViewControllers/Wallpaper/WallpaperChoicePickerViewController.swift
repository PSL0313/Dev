//
//  WallpaperChoicePickerViewController.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import UIKit

// 검색 가능한 단일·다중 선택 목록 화면을 구성하고 사용자 동작을 연결합니다.
final class WallpaperChoicePickerViewController: UITableViewController, UISearchResultsUpdating {
    private let options: [WallpaperChoice]
    private var visible: [WallpaperChoice]
    private var selected: Set<String>
    private let multiple: Bool
    private let search = UISearchController(searchResultsController: nil)
    var onSelect: ((Set<String>) -> Void)?
    init(title: String, options: [WallpaperChoice], selected: Set<String>, multiple: Bool = false) {
        self.options = options
        visible = options
        self.selected = selected
        self.multiple = multiple
        super.init(style: .insetGrouped)
        self.title = title
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = search
        definesPresentationContext = true
        if multiple {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "완료", primaryAction: UIAction { [weak self] _ in self?.finish() })
        }
    }
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        visible = query.isEmpty ? options : options.filter { $0.title.localizedCaseInsensitiveContains(query) }
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { visible.count }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = visible[indexPath.row].title
        cell.accessoryType = selected.contains(visible[indexPath.row].id) ? .checkmark : .none
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = visible[indexPath.row].id
        if multiple {
            if selected.contains(id) { selected.remove(id) } else { selected.insert(id) }
            tableView.reloadRows(at: [indexPath], with: .none)
        } else {
            selected = [id]
            finish()
        }
    }
    private func finish() {
        onSelect?(selected)
        navigationController?.popViewController(animated: true)
    }
}
