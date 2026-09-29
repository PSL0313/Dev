//
//  WallpaperStatusView.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import SnapKit
import UIKit

// 로딩·오류·빈 목록 안내와 재시도 버튼을 표시하는 재사용 뷰입니다.
final class WallpaperStatusView: UIView {
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let label = UILabel()
    private let retry = UIButton(type: .system)
    var onRetry: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        let stack = UIStackView(arrangedSubviews: [spinner, label, retry])
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .center
        label.textColor = WallpaperStyle.secondary
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .body)
        retry.setTitle("다시 시도", for: .normal)
        retry.tintColor = .white
        retry.addAction(UIAction { [weak self] _ in self?.onRetry?() }, for: .touchUpInside)
        addSubview(stack)
        stack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func update(loading: Bool, error: String?, empty: Bool, emptyMessage: String = "아직 배경화면이 없어요.") {
        isHidden = !loading && error == nil && !empty
        loading ? spinner.startAnimating() : spinner.stopAnimating()
        label.text = loading ? "불러오는 중…" : error ?? emptyMessage
        retry.isHidden = loading || error == nil
    }
}
