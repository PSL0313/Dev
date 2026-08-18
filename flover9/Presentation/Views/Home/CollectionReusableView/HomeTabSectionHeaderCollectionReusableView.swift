//
//  HomeTabSectionHeaderCollectionReusableView.swift
//  flover9
//
//  Created by 박선린 on 8/14/26.
//

import UIKit

// MARK: - 홈탭(뷰컨 내부 컬렉션뷰에 사용할 섹션 헤더
class HomeTabSectionHeaderCollectionReusableView: UICollectionReusableView {
    
    // MARK: - Type Properties
    static let identifier = String(describing: HomeTabSectionHeaderCollectionReusableView.self)
    
    // MARK: - Properties
    private var selectedAction: (() -> Void)?
    
    // MARK: - UI
    private lazy var sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var moreButton: UIButton = {
        let button = UIButton()
        let image = UIImage(
            systemName: "chevron.right",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12)
        )
        button.backgroundColor = .clear
        button.tintColor = .label
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .trailing
        button.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        var config = UIButton.Configuration.plain()
        config.image = image
        config.imagePlacement = .trailing
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )

        button.configuration = config
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [sectionTitleLabel, moreButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        moreButton.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
        moreButton.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            ])
    }
    
    func configure(upComingScheduleType: HomeTabSectionHeaderType, selectedAction: @escaping () -> Void) {
        sectionTitleLabel.text = upComingScheduleType.title()
        self.selectedAction = selectedAction
        stackView.isHidden = false
        moreButton.isHidden = false

        switch upComingScheduleType {
        case .member:
            stackView.isHidden = true
        case .upComingSchedule:
            return
        case .albums, .otherAlbums:
            moreButton.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sectionTitleLabel.text = nil
        self.selectedAction = nil
    }
}

private extension HomeTabSectionHeaderCollectionReusableView {
    @objc func didTapMoreButton() {
        selectedAction?()
    }
}
