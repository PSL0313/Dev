//
//  LoadingStateView.swift
//  flover9
//
//  Created by 박선린 on 9/15/26.
//

import UIKit
import SnapKit


/// 로딩중 화면
class LoadingStateView: UIView {
    
    // MARK: - UI
    
    private let spinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .label
        indicator.startAnimating()
        return indicator
    }()
    
    private let label: UILabel = {
        let l = UILabel()
        l.text = "Loading..."
        l.numberOfLines = 1
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .label
        l.textAlignment = .center
        return l
    }()
    
    private lazy var stackView: UIStackView = {
        let stv = UIStackView(arrangedSubviews: [spinner, label])
        stv.spacing = 4
        stv.alignment = .center
        stv.axis = .vertical
        
        return stv
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.centerX.equalTo(self.snp.centerX)
            $0.centerY.equalTo(self.snp.centerY)
        }
    }
    
}
