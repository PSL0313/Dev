//
//  UIViewController+Wallpaper.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import SnapKit
import UIKit

// Wallpaper 화면에서 공통 안내·오류 알림을 표시합니다.
extension UIViewController {
    func wallpaperAlert(_ message: String, title: String = "안내") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
