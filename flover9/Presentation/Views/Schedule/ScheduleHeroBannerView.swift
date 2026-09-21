//
//  ScheduleHeroBannerView.swift
//  flover9
//
//  Created by 박선린 on 9/11/26.
//

import UIKit
import SnapKit
import Kingfisher

// 배너
class ScheduleHeroBannerView: UIControl {
    
    // MARK: - UI
    /// 배너 이미지뷰
    lazy var bannerView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "flover9Banner")
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
    
    func configure(with url: URL?) {
        if let url {
            self.bannerView.image = nil
            bannerView.kf.setImage(
                with: url,
                options: [
                    .transition(.fade(0.25))
                ]
            )
        }
    }
}

private extension ScheduleHeroBannerView {
    func layoutConfiguration() {
        self.backgroundColor = .clear
        
        addSubview(bannerView)
        bannerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
    }
}
