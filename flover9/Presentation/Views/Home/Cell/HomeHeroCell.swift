//
//  HomeHeroCell.swift
//  flover9
//
//  Created by 박선린 on 8/17/26.
//
import UIKit


// MARK: - 홈 상단 셀
final class HomeHeroCell: UICollectionViewCell {

    static let reuseIdentifier = String(describing: HomeHeroCell.self)

    // MARK: - UI
    private let heroView = HeroView()

    // MARK: - Properties
    var didTapMember: ((MemberEntity) -> Void)? {
        didSet {
            self.heroView.didtapMember = didTapMember
        }
    }


    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(heroView)

        heroView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heroView.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(members: [MemberEntity]) {
        let introURL = URL(
            string: "https://media.flover9.com/home-hero/glow-me/intro/master.m3u8"
        )!

        let loopURL = URL(
            string: "https://media.flover9.com/home-hero/glow-me/loop/master.m3u8"
        )!

        heroView.configure(introURL: introURL, loopURL: loopURL, members: members)
    }
}
