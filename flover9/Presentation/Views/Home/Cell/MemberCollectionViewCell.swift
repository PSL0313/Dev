//
//  MemberCollectionViewCell.swift
//  flover9
//
//  Created by 박선린 on 8/11/26.
//
import UIKit
import Kingfisher

// MARK: - 홈 화면에서 멤버 한 명을 표시하는 컬렉션뷰 셀
final class MemberCollectionViewCell: UICollectionViewCell {

    // MARK: - 컬렉션뷰에서 셀을 구분하기 위한 식별자
    static let reuseIdentifier = String(describing: MemberCollectionViewCell.self)

    // MARK: - UI
    // 멤버 사진을 표시하는 이미지뷰
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()

    // MARK: - 코드로 셀을 생성할 때 호출되는 초기화 함수
    override init(frame: CGRect) {
        super.init(frame: frame)

        setLayout()                             // 셀 내부 화면 구성
    }

    // MARK: - Storyboard 및 XIB 초기화를 사용하지 않도록 제한
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 재사용되기 전 기존 데이터 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()       // 이전 이미지 다운로드 취소
        imageView.image = nil                   // 이전 멤버 사진 제거
    }

    // MARK: - 전달받은 멤버 정보를 셀에 표시
    func configure(with member: MemberEntity?) {
        imageView.kf.setImage(with: member?.profileImageURL) // 멤버 이미지 표시(kf)
    }
}


// MARK: - Layout
private extension MemberCollectionViewCell {

    // MARK: - 셀 내부 레이아웃 설정
    func setLayout() {
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            
            imageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 2
            ),
            imageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -2
            ),
            imageView.heightAnchor.constraint(
                equalTo: imageView.widthAnchor,
                multiplier: 5.0 / 4.0
            ),  // 사진 비율 5 : 4 비율
            
        ])
    }
}
