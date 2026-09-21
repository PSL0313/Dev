//
//  ScheduleDescriptionView.swift
//  flover9
//
//  Created by 박선린 on 9/21/26.
//

import UIKit
import SnapKit

final class ScheduleDescriptionView: UIView {
    // MARK: - UI
    private let title: UILabel = {
        let v = UILabel()
        
        v.font = .systemFont(ofSize: 20, weight: .bold, width: .standard)
        v.textColor = .label
        v.numberOfLines = 1
        v.textAlignment = .left
        return v
    }()
    
    private let descriptionLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 14, weight: .bold, width: .standard)
        v.textColor = .label
        v.numberOfLines = 0
        v.textAlignment = .left
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        addSubview(title)
        addSubview(descriptionLabel)
        
        title.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(15)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(15)
            $0.leading.trailing.bottom.equalToSuperview().inset(15)
        }
    }
    
    func configure(title: String = "소개", discription: String) {
        self.title.text = title
        self.descriptionLabel.text = discription
    }
}
