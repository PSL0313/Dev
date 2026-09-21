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
    
    // MARK: - Action(Closure)
    
    private var frommURL: URL?
    private var instagramURL: URL?
    
    
    static let reuseIdentifier = "FeedProfileHeaderView"

    private let avatarImageView = UIImageView()
    
    private let nameLabel = UILabel()

    private let isCaptinLabel = UILabel()

    private let birthdayLabel = UILabel()
    
    private lazy var frommButton: UIButton = {
        let btn = UIButton()
        let logoImage = UIImage(named: "frommLogo")
        btn.setImage(logoImage, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.imageView?.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 48, height: 12))
        }
        btn.backgroundColor = .secondarySystemBackground
        btn.layer.cornerRadius = 20.0 / 3.0
        btn.layer.masksToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
    
        
        btn.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                openFromm(appURL: self.frommURL)
            },
            for: .touchUpInside
        )
        
        return btn
    }()
    
    private lazy var instagramButton: UIButton = {
        let btn = UIButton()
        let logoImage = UIImage(named: "instagramLogo")
        btn.setImage(logoImage, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.imageView?.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 44.0 / 3.0, height: 44.0 / 3.0))
        }
        btn.backgroundColor = .secondarySystemBackground
        btn.layer.cornerRadius = 20.0 / 3.0
        btn.layer.masksToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
    
        
        btn.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                
                openInstagram(appURL: self.instagramURL)
            },
            for: .touchUpInside
        )
        
        return btn
    }()
    
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
        isCaptinLabel.text = nil
        isCaptinLabel.isHidden = true
        birthdayLabel.text = nil
        birthdayLabel.isHidden = true
    }

    func configure(with member: MemberEntity) {
        nameLabel.text = member.displayName
        isCaptinLabel.text = member.code == "hayoung" ? "[ Captin ]" : nil
        isCaptinLabel.isHidden = member.code != "hayoung"
        birthdayLabel.text = birthdayText(from: member.birthDate)
        birthdayLabel.isHidden = member.birthDate == nil
        
        frommURL = member.frommURL
        instagramURL = member.instagramURL
        

        let scale = self.window?.windowScene?.screen.scale ?? 3.0
        if let url = member.profileImageURL {
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
        addSubview(isCaptinLabel)
        addSubview(birthdayLabel)
        addSubview(dividerView)
        addSubview(gridIconView)
        addSubview(frommButton)
        addSubview(instagramButton)
    }

    private func configureStyle() {
        backgroundColor = .systemBackground

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 44
        avatarImageView.backgroundColor = .systemBackground
        avatarImageView.tintColor = .systemBackground

        nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        isCaptinLabel.font = .systemFont(ofSize: 11, weight: .regular)
        isCaptinLabel.textColor = .secondaryLabel

        birthdayLabel.font = .systemFont(ofSize: 11, weight: .regular)
        birthdayLabel.textColor = .secondaryLabel
        birthdayLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
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
        
        isCaptinLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(20)
            make.top.equalTo(avatarImageView)
            make.size.equalTo(CGSize(width: 52, height: 14))
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(isCaptinLabel)
            make.top.equalTo(isCaptinLabel.snp.bottom).offset(2)
        }

        birthdayLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(8)
            make.firstBaseline.equalTo(nameLabel.snp.firstBaseline)
            make.trailing.lessThanOrEqualToSuperview().inset(20)
        }

        frommButton.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: 64, height: 24))
        }

        instagramButton.snp.makeConstraints { make in
            make.leading.equalTo(frommButton.snp.trailing).offset(8)
            make.centerY.equalTo(frommButton)
            make.trailing.lessThanOrEqualToSuperview().inset(20)
            make.size.equalTo(CGSize(width: 88.0 / 3.0, height: 24))
        }

        dividerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(avatarImageView.snp.bottom).offset(18)
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


private extension FeedProfileHeaderView {
    func birthdayText(from birthDate: Date?) -> String? {
        guard let birthDate else { return nil }

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: birthDate)
    }

    func openFromm(
        appURL: URL?
    ) {
        guard let appURL else { return }
        UIApplication.shared.open(
            appURL,
            options: [:]
        ) { success in
            guard !success else { return }

            UIApplication.shared.open(
                URL(string:"https://apps.apple.com/app/id1641293296")!,
                options: [:]
            )
        }
    }
    
    func openInstagram(
        appURL: URL?
    ) {
        guard let appURL else { return }
        UIApplication.shared.open(
            appURL,
            options: [:]
        ) { success in
            guard !success else { return }
            
            
            UIApplication.shared.open(
                URL(string:"https://apps.apple.com/app/id389801252")!,
                options: [:]
            )
        }
    }
}
