//
//  SectionBackgroundView.swift
//  flover9
//
//  Created by 박선린 on 8/13/26.
//
import UIKit

final class SectionBackgroundView: UICollectionReusableView {
    
    static let identifier: String = String(describing: SectionBackgroundView.self)


    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous
        
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
