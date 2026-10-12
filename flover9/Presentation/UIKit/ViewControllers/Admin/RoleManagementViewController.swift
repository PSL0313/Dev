//
//  RoleManagementViewController.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

import UIKit
import SnapKit

// 회원을 닉네임·ID로 검색하고 현재 역할을 확인하는 관리 목록입니다.
final class RoleManagementViewController: UITableViewController, UISearchBarDelegate {
    private let viewModel: RoleManagementViewModel
    private let searchBar = UISearchBar()
    private let moreButton = UIButton(type: .system)
    private let status = UILabel()
    var onSelect: ((RoleMember, UserAuthorization) -> Void)?
    init(viewModel: RoleManagementViewModel) {
        self.viewModel = viewModel
        super.init(style: .insetGrouped)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "회원 권한 관리"
        searchBar.placeholder = "닉네임 또는 회원 ID"
        searchBar.tintColor = AdminStyle.accent
        searchBar.searchTextField.textColor = .label
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "닉네임 또는 회원 ID", attributes: [.foregroundColor: UIColor.secondaryLabel])
        searchBar.searchTextField.leftView?.tintColor = .secondaryLabel
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.frame.size.height = 56
        tableView.tableHeaderView = searchBar
        tableView.keyboardDismissMode = .onDrag
        status.font = .preferredFont(forTextStyle: .body)
        status.textColor = .secondaryLabel
        status.textAlignment = .center
        status.numberOfLines = 0
        let background = UIView()
        background.addSubview(status)
        status.snp.makeConstraints { $0.center.equalToSuperview(); $0.leading.trailing.equalToSuperview().inset(24) }
        tableView.backgroundView = background
        moreButton.setTitle("회원 더 보기", for: .normal)
        moreButton.frame.size.height = 56
        moreButton.addAction(UIAction { [weak self] _ in self?.viewModel.load(more: true) }, for: .touchUpInside)
        refreshControl = UIRefreshControl()
        refreshControl?.addAction(UIAction { [weak self] _ in self?.viewModel.load() }, for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .refresh, primaryAction: UIAction { [weak self] _ in self?.viewModel.load() })
        viewModel.onChange = { [weak self] in self?.render() }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }
    private func render() {
        let busy = viewModel.isLoading || viewModel.isSaving
        tableView.reloadData()
        status.text = viewModel.isLoading ? "회원과 권한을 확인하고 있어요." : viewModel.message
        status.isHidden = !viewModel.members.isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = !busy
        searchBar.isUserInteractionEnabled = !viewModel.isSaving
        navigationItem.hidesBackButton = viewModel.isSaving
        navigationController?.interactivePopGestureRecognizer?.isEnabled = !viewModel.isSaving
        if !viewModel.isLoading { refreshControl?.endRefreshing() }
        moreButton.isEnabled = !busy
        tableView.tableFooterView = viewModel.hasMore ? moreButton : nil
        title = viewModel.isSaving ? "권한 변경 중…" : "회원 권한 관리"
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel.load(query: searchBar.text ?? "")
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty { viewModel.load(query: "") }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { viewModel.members.count }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let member = viewModel.members[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        var content = cell.defaultContentConfiguration()
        content.text = "\(member.displayName) · \(member.roleTitle)"
        content.secondaryText = member.id.uuidString
        content.secondaryTextProperties.font = .preferredFont(forTextStyle: .caption2)
        content.secondaryTextProperties.numberOfLines = 0
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !viewModel.isLoading, !viewModel.isSaving, let access = viewModel.access else { return }
        onSelect?(viewModel.members[indexPath.row], access)
    }
}
