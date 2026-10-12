//
//  FeedStatusFooterView.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//
import UIKit
import SnapKit

final class FeedStatusFooterView: UICollectionReusableView {
    static let reuseIdentifier = "FeedStatusFooterView"

    private let messageLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground

        messageLabel.font = .systemFont(ofSize: 13, weight: .medium)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center

        addSubview(messageLabel)
        addSubview(activityIndicator)

        activityIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(12)
        }

        messageLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(activityIndicator.snp.bottom).offset(8)
            make.bottom.equalToSuperview().inset(12)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicator.stopAnimating()
        messageLabel.text = nil
        messageLabel.isHidden = true
    }

    func configure(with viewModel: MemberProfileViewModel) {
        if viewModel.isLoadingMore {
            activityIndicator.startAnimating()
            messageLabel.text = "불러오는 중..."
        } else {
            activityIndicator.stopAnimating()
            messageLabel.text = viewModel.footerMessage
        }

        messageLabel.isHidden = messageLabel.text == nil
    }
}
