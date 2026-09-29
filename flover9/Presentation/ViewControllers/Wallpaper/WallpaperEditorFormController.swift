//
//  WallpaperEditorFormController.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import SnapKit
import UIKit

// 편집 화면의 공통 입력 행과 저장 전 닫기 확인을 처리하는 공통 기반입니다.
class WallpaperEditorFormController: UITableViewController {
    var formRows: [[UITableViewCell]] = []
    var headings: [String] = []
    var footers: [String?] = []
    var dirty: (() -> Bool)?
    var busy: (() -> Bool)?
    var onClose: (() -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        tableView.keyboardDismissMode = .interactive
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "닫기", primaryAction: UIAction { [weak self] _ in self?.close() })
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    private func close() {
        guard busy?() != true else { return }
        guard dirty?() == true else {
            onClose?()
            return
        }
        let alert = UIAlertController(title: "편집을 닫을까요?", message: "저장하지 않은 변경 사항이 있어요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "계속 편집", style: .cancel))
        alert.addAction(UIAlertAction(title: "닫기", style: .destructive) { [weak self] _ in self?.onClose?() })
        present(alert, animated: true)
    }
    override func numberOfSections(in tableView: UITableView) -> Int { formRows.count }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        formRows[section].count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        formRows[indexPath.section][indexPath.row]
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        headings[section]
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        footers.indices.contains(section) ? footers[section] : nil
    }
    func fieldCell(_ field: UIView, height: CGFloat = 48) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.contentView.addSubview(field)
        field.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
            $0.height.greaterThanOrEqualTo(height)
        }
        return cell
    }
    func switchCell(_ title: String, control: UISwitch) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = title
        cell.accessoryView = control
        cell.selectionStyle = .none
        return cell
    }
}
