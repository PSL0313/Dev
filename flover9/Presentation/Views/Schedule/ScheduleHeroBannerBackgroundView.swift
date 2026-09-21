//
//  ScheduleHeroBannerBackgroundView.swift
//  flover9
//
//  Created by 박선린 on 9/11/26.
//

import UIKit
import SnapKit
import Kingfisher

// 배너
class ScheduleHeroBannerBackgroundView: UIControl {
    
    // MARK: - UI
    /// 배너 백그라운드이미지뷰
    lazy var bannerBackgroundView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "flover9Banner")
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        iv.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return iv
    }()
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        layoutConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    func configure(with url: URL) {
        UIView.performWithoutAnimation {
            bannerBackgroundView.image = nil
            bannerBackgroundView.kf.setImage(with: url)
        }
    }
}

private extension ScheduleHeroBannerBackgroundView {
    func layoutConfiguration() {
        self.backgroundColor = .clear
        
        addSubview(bannerBackgroundView)
        bannerBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
