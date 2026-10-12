//
//  WallpaperStyle.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import SnapKit
import UIKit

// Wallpaper 화면에서 공유하는 색상, 내비게이션 스타일, 이미지 로딩 처리를 모읍니다.
enum WallpaperStyle {
    static let background = UIColor.clear
    static let surface = UIColor(white: 0.12, alpha: 1)
    static let secondary = UIColor(white: 0.68, alpha: 1)
    static func navigation(_ navigation: UINavigationController) {
        navigation.overrideUserInterfaceStyle = .dark
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigation.navigationBar.standardAppearance = appearance
        navigation.navigationBar.scrollEdgeAppearance = appearance
        navigation.navigationBar.tintColor = .white
    }
    static func image(
        _ view: UIImageView,
        url: URL?,
        completion: ((UIImage?) -> Void)? = nil
    ) {
        view.kf.cancelDownloadTask()
        view.image = nil
        view.backgroundColor = surface
        view.kf.setImage(
            with: url,
            options: [.transition(.fade(0.15))]
        ) { result in
            switch result {
            case .success(let value):
                completion?(value.image)
                
            case .failure:
                completion?(nil)
            }   
        }
    }
}
