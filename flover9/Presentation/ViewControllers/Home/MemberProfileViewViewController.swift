//
//  MemberProfileViewViewController.swift
//  flover9
//
//  Created by 박선린 on 8/14/26.
//

import UIKit
import SnapKit

import UIKit
import SnapKit
import Kingfisher

final class MemberProfileViewViewController: UIViewController {

    private let member: MemberEntity

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 60
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private let codeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let sortOrderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        return label
    }()

    private let activeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        return label
    }()

    private let entityTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        return label
    }()

    private let createdAtLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    init(_ member: MemberEntity) {
        self.member = member
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Deinit
    deinit { print("MemberProfileViewViewController deinit") }

    override func viewDidLoad() {
        super.viewDidLoad()

        setLayout()
        configure()
    }

    private func setLayout() {
        view.backgroundColor = .systemBackground

        let infoStackView = UIStackView(arrangedSubviews: [
            sortOrderLabel,
            activeLabel,
            entityTypeLabel,
            createdAtLabel
        ])

        infoStackView.axis = .vertical
        infoStackView.spacing = 12
        infoStackView.alignment = .fill

        let stackView = UIStackView(arrangedSubviews: [
            profileImageView,
            nameLabel,
            codeLabel,
            infoStackView
        ])

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill

        view.addSubview(stackView)

        profileImageView.snp.makeConstraints {
            $0.width.equalTo(160)
            $0.height.equalTo(200)
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        profileImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
        }
    }

    private func configure() {
        nameLabel.text = member.displayName
        codeLabel.text = member.code
        sortOrderLabel.text = "정렬 순서: \(member.sortOrder)"
        activeLabel.text = "활성 상태: \(member.isActive ? "활성" : "비활성")"
        entityTypeLabel.text = "Entity Type: \(member.entityType)"
        createdAtLabel.text = "생성 시각: \(member.createdAt.formatted())"

        if let url = member.profileImageURL {
            profileImageView.kf.setImage(with: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        }
    }
}
