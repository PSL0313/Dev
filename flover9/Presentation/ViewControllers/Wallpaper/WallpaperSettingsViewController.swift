//
//  WallpaperSettingsViewController.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import UIKit

// Wallpaper 안내·관리 진입·서비스 닫기 화면을 구성하고 사용자 동작을 연결합니다.
final class WallpaperSettingsViewController: UITableViewController {
    var canManage = false { didSet { if isViewLoaded { tableView.reloadData() } } }
    var onManage: (() -> Void)?
    var onClose: (() -> Void)?
    init() { super.init(style: .insetGrouped) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "설정"
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { canManage ? 4 : 3 }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = ["다운로드 안내", "즐겨찾기 안내", "flover9 홈으로", "시리즈 관리"][indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0: wallpaperAlert("미리보기의 다운로드 버튼을 누른 뒤 ‘이미지 저장’ 또는 ‘파일에 저장’을 선택하세요. 기기 배경화면은 사진 또는 설정 앱에서 지정할 수 있습니다.")
        case 1: wallpaperAlert("즐겨찾기는 이 기기에 저장됩니다. 원본이 삭제되거나 교체되면 이전에 저장한 항목은 다시 다운로드할 수 없을 수 있습니다.")
        case 2: onClose?()
        default: onManage?()
        }
    }
}
