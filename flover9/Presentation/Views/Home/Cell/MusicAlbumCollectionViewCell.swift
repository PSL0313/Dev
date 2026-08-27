//
//  MusicAlbumCollectionViewCell.swift
//  flover9
//

import UIKit
import MusicKit
import Kingfisher

// MARK: - 앨범 표지와 기본 정보를 표시하는 컬렉션뷰 셀
final class MusicAlbumCollectionViewCell: UICollectionViewCell {

    /// 컬렉션뷰 셀 등록과 재사용에 사용하는 식별자입니다.
    static let reuseIdentifier = String(
        describing: MusicAlbumCollectionViewCell.self
    )

    // MARK: - UI

    /// 정사각형 앨범 표지를 표시합니다.
    private let artworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    /// 앨범명을 표시합니다.
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// 앨범 발매일을 표시합니다.
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()

        artworkImageView.kf.cancelDownloadTask()
        artworkImageView.image = nil
        titleLabel.text = nil
        releaseDateLabel.text = nil
    }

    // MARK: - Configuration

    /// MusicKit에서 조회한 앨범 정보를 셀에 표시합니다.
    func configure(with album: Album) {
        titleLabel.text = album.title

        releaseDateLabel.text = album.releaseDate?.formatted(
            date: .abbreviated,
            time: .omitted
        )

        let artworkURL = album.artwork?.url(
            width: 600,
            height: 600
        )

        artworkImageView.kf.setImage(with: artworkURL)
    }
}

// MARK: - Layout
private extension MusicAlbumCollectionViewCell {

    /// 표지는 정사각형으로 배치하고 그 아래에 앨범명과 발매일을 쌓습니다.
    func setLayout() {
        contentView.addSubview(artworkImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(releaseDateLabel)

        NSLayoutConstraint.activate([
            artworkImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            artworkImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            artworkImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            artworkImageView.heightAnchor.constraint(
                equalTo: artworkImageView.widthAnchor
            ),

            titleLabel.topAnchor.constraint(
                equalTo: artworkImageView.bottomAnchor,
                constant: 8
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),

            releaseDateLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 3
            ),
            releaseDateLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            releaseDateLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            releaseDateLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor
            )
        ])
    }
}
