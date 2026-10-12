//
//  UITableViewController+Wallpaper.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import SnapKit
import UIKit

// Wallpaper 관리 목록의 로딩·빈 상태와 삭제 확인을 공통 처리합니다.
extension UITableViewController {
    func wallpaperListStatus(loading: Bool, error: String?, empty: Bool, retry: @escaping () -> Void) {
        if empty || error != nil {
            var config = UIContentUnavailableConfiguration.empty()
            config.text = loading ? "불러오는 중…" : error ?? "아직 등록된 항목이 없어요."
            config.secondaryText = loading ? nil : "추가 버튼으로 새로운 항목을 등록할 수 있어요."
            if error != nil {
                config.button.title = "다시 시도"
                config.buttonProperties.primaryAction = UIAction { _ in retry() }
            }
            contentUnavailableConfiguration = config
        } else {
            contentUnavailableConfiguration = nil
        }
    }
    func confirmWallpaperDeletion(_ title: String, perform: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "‘\(title)’ 삭제", message: "연결된 이미지도 삭제됩니다. 이 작업은 되돌릴 수 없어요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in perform() })
        present(alert, animated: true)
    }
}
