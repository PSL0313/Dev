//
//  StreamingShortcutCell.swift
//  flover9
//
//  Created by 박선린 on 8/17/26.
//
import UIKit
import SnapKit
import Kingfisher

// MARK: - 스트리밍 바로가기 셀
final class StreamingShortcutCell: UICollectionViewCell {

    static let reuseIdentifier = String(describing: StreamingShortcutCell.self)

    // MARK: - UI

    private let rootView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.08)
        v.layer.cornerRadius = 14
        v.layer.cornerCurve = .continuous
        v.layer.masksToBounds = true
        return v
    }()

    /// 오른쪽 단체 이미지
    private let coreImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()

    /// Melon 심볼
    private let melonLogoImageView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "MelonLogo")
        v.contentMode = .scaleAspectFit
        return v
    }()

    private let melonLabel: UILabel = {
        let v = UILabel()
        v.text = "Musicwave"
        v.font = .systemFont(ofSize: 25, weight: .bold)
        v.textColor = .white
        return v
    }()

    private let brandStackView: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.spacing = 7
        v.alignment = .center
        return v
    }()

    private let musicwaveLabel: UILabel = {
        let v = UILabel()
        v.text = "Musicwave"
        v.font = .systemFont(ofSize: 18, weight: .semibold)
        v.textColor = .label
        return v
    }()

    /// 초록색 원형 화살표
    private let shortcutIconView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemGreen
        v.layer.cornerRadius = 19
        return v
    }()

    private let shortcutIconImageView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(systemName: "arrow.right")
        v.tintColor = .white
        v.contentMode = .scaleAspectFit
        return v
    }()

    private let shortcutLabel: UILabel = {
        let v = UILabel()
        v.text = "바로가기"
        v.font = .systemFont(ofSize: 15, weight: .semibold)
        v.textColor = .label
        return v
    }()

    private let chevronImageView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(systemName: "chevron.right")
        v.tintColor = .tertiaryLabel
        v.contentMode = .scaleAspectFit
        return v
    }()

    private let shortcutStackView: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.spacing = 9
        v.alignment = .center
        return v
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureHierarchy()
        configureLayout()
        configureImage()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Hierarchy

    private func configureHierarchy() {
        contentView.addSubview(rootView)

        rootView.addSubview(coreImageView)

        rootView.addSubview(brandStackView)
        brandStackView.addArrangedSubview(melonLogoImageView)
        brandStackView.addArrangedSubview(melonLabel)

        rootView.addSubview(musicwaveLabel)

        rootView.addSubview(shortcutStackView)

        shortcutStackView.addArrangedSubview(shortcutIconView)
        shortcutIconView.addSubview(shortcutIconImageView)

        shortcutStackView.addArrangedSubview(shortcutLabel)
        shortcutStackView.addArrangedSubview(chevronImageView)
    }

    // MARK: - Layout

    private func configureLayout() {
        rootView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // 오른쪽 이미지
        coreImageView.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.44)
        }

        // Melon
        brandStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.lessThanOrEqualTo(coreImageView.snp.leading).offset(-12)
        }

        melonLogoImageView.snp.makeConstraints {
            $0.width.height.equalTo(28)
        }

        // Musicwave
        musicwaveLabel.snp.makeConstraints {
            $0.top.equalTo(brandStackView.snp.bottom).offset(4)
            $0.leading.equalTo(brandStackView)
            $0.trailing.lessThanOrEqualTo(coreImageView.snp.leading).offset(-12)
        }

        // 바로가기
        shortcutStackView.snp.makeConstraints {
            $0.leading.equalTo(brandStackView)
            $0.bottom.equalToSuperview().inset(18)
            $0.trailing.lessThanOrEqualTo(coreImageView.snp.leading).offset(-12)
        }

        shortcutIconView.snp.makeConstraints {
            $0.width.height.equalTo(38)
        }

        shortcutIconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(17)
        }

        chevronImageView.snp.makeConstraints {
            $0.width.equalTo(7)
            $0.height.equalTo(13)
        }
    }

    // MARK: - Image

    private func configureImage() {
        let url = URL(
            string: "https://media.flover9.com/MembersProfileImage/20260721/fromis9.jpeg"
        )

        coreImageView.kf.setImage(with: url)
    }
}
