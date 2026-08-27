//
//  TestAlbumDetailViewController.swift
//  flover9
//

import UIKit
import MusicKit
import Kingfisher

/// Apple Music의 앨범 화면 구성을 참고한 테스트용 상세 화면입니다.
/// 별도의 ViewModel 없이 전달받은 `Album`을 직접 표시하고 재생을 제어합니다.
final class TestAlbumDetailViewController: UIViewController {

    // MARK: - Properties

    private let album: Album
    private let musicPlayer = TestMusicPlayer.shared
    private var tracks: [Track] = []

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// 앨범 표지를 Stack View 안에서 가운데 정렬하기 위한 컨테이너입니다.
    private let artworkContainerView = UIView()

    private let artworkImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .secondarySystemBackground
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel = TestAlbumDetailViewController.makeLabel(
        font: .preferredFont(forTextStyle: .title2),
        color: .label,
        alignment: .center,
        lines: 0
    )

    private let artistLabel = TestAlbumDetailViewController.makeLabel(
        font: .preferredFont(forTextStyle: .title3),
        color: .label,
        alignment: .center,
        lines: 0
    )

    private let summaryLabel = TestAlbumDetailViewController.makeLabel(
        font: .preferredFont(forTextStyle: .subheadline),
        color: .secondaryLabel,
        alignment: .center,
        lines: 1
    )

    private let editorialLabel = TestAlbumDetailViewController.makeLabel(
        font: .preferredFont(forTextStyle: .body),
        color: .secondaryLabel,
        alignment: .left,
        lines: 0
    )

    private let trackStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    private let footerLabel = TestAlbumDetailViewController.makeLabel(
        font: .preferredFont(forTextStyle: .footnote),
        color: .secondaryLabel,
        alignment: .left,
        lines: 0
    )

    private lazy var shuffleButton = makeCircleButton(
        systemName: "shuffle",
        accessibilityLabel: "앨범 셔플 재생",
        action: #selector(didTapShuffleButton)
    )

    private lazy var playButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "재생"
        configuration.image = UIImage(systemName: "play.fill")
        configuration.imagePadding = 8
        configuration.baseBackgroundColor = .label
        configuration.baseForegroundColor = .systemBackground
        configuration.cornerStyle = .capsule

        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 54).isActive = true
        return button
    }()

    private lazy var addButton = makeCircleButton(
        systemName: "plus",
        accessibilityLabel: "재생 대기열에 추가",
        action: #selector(didTapAddButton)
    )

    private lazy var actionStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [shuffleButton, playButton, addButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()

    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            artworkContainerView,
            titleLabel,
            artistLabel,
            summaryLabel,
            actionStackView,
            editorialLabel,
            trackStackView,
            footerLabel
        ])
        stack.axis = .vertical
        stack.spacing = 8
        stack.setCustomSpacing(20, after: artworkContainerView)
        stack.setCustomSpacing(20, after: summaryLabel)
        stack.setCustomSpacing(24, after: actionStackView)
        stack.setCustomSpacing(18, after: editorialLabel)
        stack.setCustomSpacing(22, after: trackStackView)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Initializer

    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        setLayout()
        configureAlbum()
    }
}

// MARK: - Configuration
private extension TestAlbumDetailViewController {

    func configureNavigationBar() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "ellipsis"),
                style: .plain,
                target: nil,
                action: nil
            ),
            UIBarButtonItem(
                image: UIImage(systemName: "square.and.arrow.up"),
                style: .plain,
                target: nil,
                action: nil
            )
        ]
    }

    func configureAlbum() {
        titleLabel.text = album.title
        artistLabel.text = album.artistName

        let year = album.releaseDate?.formatted(.dateTime.year()) ?? ""
        let genre = album.genreNames.first ?? ""
        let kind = album.isSingle == true ? "싱글" : "앨범"
        summaryLabel.text = [genre, year, kind]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")

        editorialLabel.text = album.editorialNotes?.short
            ?? album.editorialNotes?.standard
        editorialLabel.isHidden = editorialLabel.text?.isEmpty != false

        artworkImageView.kf.setImage(
            with: album.artwork?.url(width: 1000, height: 1000)
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let value):
                UIView.animate(withDuration: 1.1, animations: {
                    self.view.backgroundColor = value.image.averageColor()
                })
            case .failure:
                break
            }
        }

        tracks = album.tracks.map { Array($0) } ?? []
        configureTrackRows()
        configureFooter()
    }

    func configureTrackRows() {
        for (index, track) in tracks.enumerated() {
            let row = UIButton(type: .system)
            row.tag = index
            row.contentHorizontalAlignment = .leading
            row.setTitleColor(.label, for: .normal)
            row.titleLabel?.font = .preferredFont(forTextStyle: .body)
            row.setTitle("\(index + 1)    \(title(of: track))", for: .normal)
            row.addTarget(self, action: #selector(didTapTrack(_:)), for: .touchUpInside)

            let moreImage = UIImageView(image: UIImage(systemName: "ellipsis"))
            moreImage.tintColor = .secondaryLabel
            moreImage.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview(moreImage)

            NSLayoutConstraint.activate([
                row.heightAnchor.constraint(greaterThanOrEqualToConstant: 58),
                moreImage.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                moreImage.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -4)
            ])

            let separator = UIView()
            separator.backgroundColor = .separator
            separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true

            trackStackView.addArrangedSubview(row)
            trackStackView.addArrangedSubview(separator)
        }
    }

    func configureFooter() {
        let releaseDate = album.releaseDate?.formatted(
            .dateTime.locale(Locale(identifier: "ko_KR")).year().month().day()
        ) ?? "발매일 정보 없음"

        let totalDuration = tracks.reduce(TimeInterval.zero) {
            $0 + duration(of: $1)
        }
        let roundedMinutes = Int((totalDuration / 60).rounded())
        let trackText = "\(tracks.count)곡, \(roundedMinutes)분"
        let copyright = album.copyright ?? ""

        footerLabel.text = [releaseDate, trackText, copyright]
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }

    func title(of track: Track) -> String {
        switch track {
        case .song(let song): song.title
        case .musicVideo(let video): video.title
        @unknown default: "알 수 없는 트랙"
        }
    }

    func duration(of track: Track) -> TimeInterval {
        switch track {
        case .song(let song): song.duration ?? 0
        case .musicVideo(let video): video.duration ?? 0
        @unknown default: 0
        }
    }
}

// MARK: - Actions
private extension TestAlbumDetailViewController {

    @objc func didTapShuffleButton() {
        performMusicTask { [album, musicPlayer] in
            try await musicPlayer.shufflePlay(album: album)
        }
    }

    @objc func didTapPlayButton() {
        performMusicTask { [album, musicPlayer] in
            try await musicPlayer.play(album: album)
        }
    }

    @objc func didTapAddButton() {
        performMusicTask(successMessage: "앨범을 대기열 마지막에 추가했습니다.") {
            [album, musicPlayer] in
            try await musicPlayer.addToQueue(album: album)
        }
    }

    @objc func didTapTrack(_ sender: UIButton) {
        guard tracks.indices.contains(sender.tag) else { return }
        let track = tracks[sender.tag]

        performMusicTask { [album, musicPlayer] in
            try await musicPlayer.play(album: album, startingAt: track)
        }
    }

    func performMusicTask(
        successMessage: String? = nil,
        operation: @escaping @MainActor () async throws -> Void
    ) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await operation()
                if let successMessage {
                    showAlert(title: "완료", message: successMessage)
                }
            } catch {
                showAlert(title: "재생 오류", message: error.localizedDescription)
            }
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - View Factory
private extension TestAlbumDetailViewController {

    static func makeLabel(
        font: UIFont,
        color: UIColor,
        alignment: NSTextAlignment,
        lines: Int
    ) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = color
        label.textAlignment = alignment
        label.numberOfLines = lines
        return label
    }

    func makeCircleButton(
        systemName: String,
        accessibilityLabel: String,
        action: Selector
    ) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: systemName)
        configuration.baseBackgroundColor = .secondarySystemFill
        configuration.baseForegroundColor = .label
        configuration.cornerStyle = .capsule

        let button = UIButton(configuration: configuration)
        button.accessibilityLabel = accessibilityLabel
        button.addTarget(self, action: action, for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 54).isActive = true
        button.heightAnchor.constraint(equalToConstant: 54).isActive = true
        return button
    }
}

// MARK: - Layout
private extension TestAlbumDetailViewController {

    func setLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        artworkContainerView.addSubview(artworkImageView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -36),

            artworkContainerView.heightAnchor.constraint(
                equalTo: contentView.widthAnchor,
                multiplier: 0.78
            ),
            artworkImageView.centerXAnchor.constraint(equalTo: artworkContainerView.centerXAnchor),
            artworkImageView.centerYAnchor.constraint(equalTo: artworkContainerView.centerYAnchor),
            artworkImageView.heightAnchor.constraint(equalTo: artworkContainerView.heightAnchor),
            artworkImageView.widthAnchor.constraint(equalTo: artworkImageView.heightAnchor),

            playButton.widthAnchor.constraint(greaterThanOrEqualTo: actionStackView.widthAnchor, multiplier: 0.48)
        ])
    }
}
