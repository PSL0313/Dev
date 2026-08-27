//
//  HeroMemberView.swift
//  flover9
//
//  Created by 박선린 on 8/17/26.
//
import UIKit
import Kingfisher
import SnapKit

final class HeroMemberView: UIControl {

    // MARK: - UI

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 14
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Properties

    private var member: MemberEntity?


    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Layout

    private func setLayout() {
        addSubview(imageView)
        addSubview(nameLabel)

        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()

            $0.height.equalTo(imageView.snp.width)
                .multipliedBy(5.0 / 4.0)
        }

        nameLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }


    // MARK: - Configure

    func configure(member: MemberEntity) {
        self.member = member

        nameLabel.text = member.displayName

        imageView.kf.setImage(
            with: member.profileImageURL
        )
    }


    // MARK: - Reuse / Reset

    func reset() {
        member = nil

        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        nameLabel.text = nil
    }
}
