//
//  FeedDetailImageCell.swift
//  flover9
//
//  Created by 박선린 on 9/1/26.
//


import UIKit
import Kingfisher
import SnapKit
import AVFoundation
final class FeedDetailImageCell: UICollectionViewCell, UIScrollViewDelegate {
    static let reuseIdentifier = "FeedDetailImageCell"
    
    private let imageView = UIImageView()
    private let scrollView = UIScrollView()
    private let videoContainerView = UIView()
    private let playerLayer = AVPlayerLayer()
    private var player: AVPlayer?
    
    private let progressView: UIProgressView =  {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor
        = .green
        return progressView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(scrollView)
        scrollView.frame = contentView.bounds
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.addSubview(imageView)

        contentView.addSubview(videoContainerView)
        videoContainerView.frame = contentView.bounds
        videoContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        videoContainerView.backgroundColor = .black
        videoContainerView.layer.addSublayer(playerLayer)
        videoContainerView.isHidden = true
        playerLayer.videoGravity = .resizeAspect
        
        imageView.frame = scrollView.bounds
        imageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(progressView)
        progressView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(50)
        }
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = contentView.bounds
        imageView.frame = scrollView.bounds
        playerLayer.frame = videoContainerView.bounds
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        scrollView.zoomScale = 1
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        playerLayer.player = nil
        videoContainerView.isHidden = true
        scrollView.isHidden = false
    }

    func configure(media: FeedImageEntity) {
        if media.contentType.isVideo {
            configureVideo(url: media.imageURL)
        } else {
            configureImage(url: media.imageURL)
        }
    }

    func playIfVideo() {
        player?.play()
    }

    func pauseVideo() {
        player?.pause()
    }

    private func configureVideo(url: URL) {
        progressView.isHidden = true
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        scrollView.isHidden = true
        videoContainerView.isHidden = false

        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .pause
        self.player = player
        playerLayer.player = player
        player.play()
    }

    private func configureImage(url: URL) {
        progressView.isHidden = true
        player?.pause()
        playerLayer.player = nil
        player = nil
        videoContainerView.isHidden = true
        scrollView.isHidden = false
        
        imageView.kf.setImage(
            with: url,
            progressBlock: { [weak self] receivedSize, totalSize in
                let progress = Float(receivedSize) / Float(totalSize)
                
                if progress == 1 {
                    self?.progressView.isHidden = true
                } else {
                    self?.progressView.isHidden = false
                    self?.progressView.progress = progress
                }
        
            }
        )
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let horizontalInset = max((scrollView.bounds.width - imageView.frame.width) / 2, 0)
        let verticalInset = max((scrollView.bounds.height - imageView.frame.height) / 2, 0)
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}
