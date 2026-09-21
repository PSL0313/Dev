//
//  ErrorStateView.swift
//  flover9
//
//  Created by 박선린 on 9/15/26.
//

import UIKit
import SnapKit

/// 해당 화면은 단순한 에러 및 실패 결과 화면이 아닌 실패시 대신 보여주는 화면이며 재시도 버튼을 클릭 가능한 화면이다.
/// 일반적으로 에러가 발생해도 대체 화면이 필요하지 않은 화면은 알럿으로 처리
final class ErrorStateView: UIView {
    
    // MARK: - Closure
    
    /// 재시도 버튼 누를시 실행되는 클로저
    var onRetry: (()->Void)?
    
    
    // MARK: - UI
    
    ///제목
    private let title: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.textAlignment = .center
        l.textColor = .label
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.text = "오류"
        return l
    }()
    
    
    ///세부 에러 메세지
    private let errorMessageLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 14, weight: .light)
        
        
        return l
    }()
    
    
    /// 재시도 버튼
    private lazy var retryBtn: UIButton = {
        let button = UIButton(type: .system)

        var configuration = UIButton.Configuration.filled()
        configuration.title = "다시 시도"
        configuration.image = UIImage(systemName: "arrow.clockwise")
        configuration.imagePadding = 6
        configuration.baseBackgroundColor = .red

        button.configuration = configuration
        button.addAction( UIAction(handler: { [weak self] _ in
            guard let self else { return }
            self.onRetry?()
        }), for: .touchUpInside)

        return button
    }()
    
    
    private lazy var stackView: UIStackView = {
        let stv = UIStackView(arrangedSubviews: [title, errorMessageLabel, retryBtn])
        stv.spacing = 8
        stv.alignment = .center
        stv.axis = .vertical
        
        return stv
    }()
    
    
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(message: String) {
        errorMessageLabel.text = message
    }
    
    func configureLayout() {
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.centerX.equalTo(self.snp.centerX)
            $0.centerY.equalTo(self.snp.centerY)
        }
    }
    
}
