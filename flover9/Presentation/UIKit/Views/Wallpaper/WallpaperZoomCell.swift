//
//  WallpaperZoomCell.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import SnapKit
import UIKit

// 미리보기의 큰 목업 이미지와 확대·축소을 표시하는 재사용 뷰입니다.
final class WallpaperZoomCell: UICollectionViewCell, UIScrollViewDelegate {
    private let scroll = UIScrollView(), image = UIImageView()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scroll.delegate = self
        scroll.minimumZoomScale = 1
        scroll.maximumZoomScale = 3
        contentView.addSubview(scroll)
        scroll.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18))
        }
        image.layer.cornerRadius = 14
        image.layer.masksToBounds = true
        image.layer.cornerCurve = .continuous
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.layer.cornerRadius = 14
        scroll.addSubview(image)
        image.snp.makeConstraints {
            $0.edges.equalTo(scroll.contentLayoutGuide)
            $0.width.height.equalTo(scroll.frameLayoutGuide)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(_ wallpaper: WallpaperEntity) {
        scroll.setZoomScale(1, animated: false)
        WallpaperStyle.image(image, url: wallpaper.mockupURL) { [weak self] image in
            guard let self, let image else { return }
            
            let ratio = image.size.height / image.size.width
            
            self.image.snp.remakeConstraints {
                $0.edges.equalTo(self.scroll.contentLayoutGuide)
                $0.width.equalTo(self.scroll.frameLayoutGuide)
                $0.height.equalTo(self.image.snp.width).multipliedBy(ratio)
            }
        }
        image.accessibilityLabel = wallpaper.displayLabel
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { image }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image.kf.cancelDownloadTask()
        image.image = nil
        scroll.setZoomScale(1, animated: false)
    }
}
