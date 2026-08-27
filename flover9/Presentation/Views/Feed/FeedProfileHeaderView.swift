//
//  FeedProfileHeaderView.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//
import UIKit
import SnapKit
import Kingfisher

final class FeedProfileHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "FeedProfileHeaderView"

    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let postsValueLabel = UILabel()
    private let photosValueLabel = UILabel()
    private let postsTitleLabel = UILabel()
    private let photosTitleLabel = UILabel()
    private let dividerView = UIView()
    private let gridIconView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureStyle()
        configureLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.kf.cancelDownloadTask()
        avatarImageView.image = nil
    }

    func configure(with viewModel: MemberProfileViewModel) {
        nameLabel.text = viewModel.displayName
        subtitleLabel.text = viewModel.subtitle
        postsValueLabel.text = viewModel.postCountText
        photosValueLabel.text = viewModel.photoCountText

        let scale = self.window?.windowScene?.screen.scale ?? 3.0
        if let url = viewModel.profileImageURL {
            avatarImageView.kf.setImage(
                with: url,
                options: [
                    .processor(DownsamplingImageProcessor(size: CGSize(width: 88, height: 88))),
                    .scaleFactor(scale)
                ]
            )
        } else {
            avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
        }
    }

    private func configureHierarchy() {
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(subtitleLabel)
        addSubview(postsValueLabel)
        addSubview(photosValueLabel)
        addSubview(postsTitleLabel)
        addSubview(photosTitleLabel)
        addSubview(dividerView)
        addSubview(gridIconView)
    }

    private func configureStyle() {
        backgroundColor = .systemBackground

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 44
        avatarImageView.backgroundColor = .systemBackground
        avatarImageView.tintColor = .systemBackground

        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textColor = .label

        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .label

        [postsValueLabel, photosValueLabel].forEach {
            $0.font = .systemFont(ofSize: 18, weight: .semibold)
            $0.textColor = .label
            $0.textAlignment = .center
        }

        postsTitleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        postsTitleLabel.textColor = .secondaryLabel
        postsTitleLabel.text = "게시물"
        postsTitleLabel.textAlignment = .center

        photosTitleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        photosTitleLabel.textColor = .secondaryLabel
        photosTitleLabel.text = "사진"
        photosTitleLabel.textAlignment = .center

        dividerView.backgroundColor = .systemBackground

        gridIconView.image = UIImage(systemName: "square.grid.3x3.fill")
        gridIconView.tintColor = .label
        gridIconView.contentMode = .scaleAspectFit
    }

    private func configureLayout() {
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(16)
            make.size.equalTo(CGSize(width: 88, height: 88))
        }

        postsValueLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView).offset(18)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(28)
            make.width.equalTo(64)
        }

        photosValueLabel.snp.makeConstraints { make in
            make.top.equalTo(postsValueLabel)
            make.leading.equalTo(postsValueLabel.snp.trailing).offset(18)
            make.width.equalTo(64)
            make.trailing.lessThanOrEqualToSuperview().inset(20)
        }

        postsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(postsValueLabel.snp.bottom).offset(4)
            make.centerX.equalTo(postsValueLabel)
        }

        photosTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(photosValueLabel.snp.bottom).offset(4)
            make.centerX.equalTo(photosValueLabel)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView)
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
            make.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
        }

        dividerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(subtitleLabel.snp.bottom).offset(18)
            make.height.equalTo(1)
        }

        gridIconView.snp.makeConstraints { make in
            make.top.equalTo(dividerView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 22, height: 22))
            make.bottom.equalToSuperview().inset(12)
        }
    }
}
