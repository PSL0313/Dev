//
//  TestMusicPlayerViewController.swift
//  flover9
//

import UIKit
import MusicKit
import MediaPlayer
import Kingfisher

/// Apple Music의 전체 화면 플레이어와 재생 목록 화면을 참고한 테스트 화면입니다.
/// 별도의 ViewModel 없이 공유 `ApplicationMusicPlayer`를 직접 표시하고 제어합니다.
final class TestMusicPlayerViewController: UIViewController {

    // MARK: - Properties

    private let musicPlayer = TestMusicPlayer.shared
    private var refreshTimer: Timer?
    private var lastArtworkURL: URL?

    // MARK: - Background

    private let backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = .systemGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.18)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Mode Selector

    private lazy var modeControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["플레이어", "재생 목록"])
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = UIColor.white.withAlphaComponent(0.28)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.addTarget(self, action: #selector(didChangeMode), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    // MARK: - Player Page

    private let playerContentView = UIView()

    private let artworkImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        view.layer.cornerRadius = 14
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel = TestMusicPlayerViewController.makeLabel(
        font: .preferredFont(forTextStyle: .title2),
        color: .white,
        alignment: .left,
        lines: 2
    )

    private let artistLabel = TestMusicPlayerViewController.makeLabel(
        font: .preferredFont(forTextStyle: .title3),
        color: UIColor.white.withAlphaComponent(0.72),
        alignment: .left,
        lines: 1
    )

    private let progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        return slider
    }()

    private let elapsedLabel = TestMusicPlayerViewController.makeLabel(
        font: .monospacedDigitSystemFont(ofSize: 13, weight: .medium),
        color: UIColor.white.withAlphaComponent(0.65),
        alignment: .left,
        lines: 1
    )

    private let remainingLabel = TestMusicPlayerViewController.makeLabel(
        font: .monospacedDigitSystemFont(ofSize: 13, weight: .medium),
        color: UIColor.white.withAlphaComponent(0.65),
        alignment: .right,
        lines: 1
    )

    private lazy var previousButton = makeControlButton(
        systemName: "backward.fill",
        pointSize: 38,
        action: #selector(didTapPrevious)
    )

    private lazy var playPauseButton = makeControlButton(
        systemName: "play.fill",
        pointSize: 58,
        action: #selector(didTapPlayPause)
    )

    private lazy var nextButton = makeControlButton(
        systemName: "forward.fill",
        pointSize: 38,
        action: #selector(didTapNext)
    )

    private lazy var playbackControlStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [previousButton, playPauseButton, nextButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalCentering
        return stack
    }()

    /// 시스템 음량을 제어하는 Apple 제공 볼륨 뷰입니다.
    private let volumeView: MPVolumeView = {
        let view = MPVolumeView(frame: .zero)
        view.showsRouteButton = false
        view.tintColor = .white
        return view
    }()

    private lazy var timeStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [elapsedLabel, remainingLabel])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var playerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            artworkImageView,
            titleLabel,
            artistLabel,
            progressSlider,
            timeStack,
            playbackControlStack,
            volumeView
        ])
        stack.axis = .vertical
        stack.spacing = 7
        stack.setCustomSpacing(30, after: artworkImageView)
        stack.setCustomSpacing(22, after: artistLabel)
        stack.setCustomSpacing(30, after: timeStack)
        stack.setCustomSpacing(55, after: playbackControlStack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Queue Page

    private let queueContentView = UIView()

    private let queueHeaderArtwork: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let queueHeaderTitle = TestMusicPlayerViewController.makeLabel(
        font: .preferredFont(forTextStyle: .headline),
        color: .white,
        alignment: .left,
        lines: 1
    )

    private let queueHeaderArtist = TestMusicPlayerViewController.makeLabel(
        font: .preferredFont(forTextStyle: .body),
        color: UIColor.white.withAlphaComponent(0.72),
        alignment: .left,
        lines: 1
    )

    private lazy var queueHeaderTextStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [queueHeaderTitle, queueHeaderArtist])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    private lazy var queueHeaderStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [queueHeaderArtwork, queueHeaderTextStack])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 14
        return stack
    }()

    private lazy var shuffleModeButton = makeQueueModeButton(
        systemName: "shuffle",
        action: #selector(didTapShuffleMode)
    )

    private lazy var repeatModeButton = makeQueueModeButton(
        systemName: "repeat",
        action: #selector(didTapRepeatMode)
    )

    private lazy var autoplayButton: UIButton = {
        let button = makeQueueModeButton(systemName: "infinity", action: nil)
        button.isEnabled = false
        button.alpha = 0.45
        return button
    }()

    private lazy var queueModeStack: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [shuffleModeButton, repeatModeButton, autoplayButton]
        )
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()

    private let continueLabel = TestMusicPlayerViewController.makeLabel(
        font: .preferredFont(forTextStyle: .title3),
        color: .white,
        alignment: .left,
        lines: 1
    )

    private let queueScrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = true
        return view
    }()

    private let queueStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var queuePageStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            queueHeaderStack,
            queueModeStack,
            continueLabel,
            queueScrollView
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.setCustomSpacing(28, after: queueModeStack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setLayout()
        configureActions()
        didChangeMode()
        refreshUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        startRefreshTimer()
        refreshUI()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopRefreshTimer()
    }

    deinit {
        refreshTimer?.invalidate()
    }
}

// MARK: - Refresh
private extension TestMusicPlayerViewController {

    func startRefreshTimer() {
        stopRefreshTimer()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) {
            [weak self] _ in
            self?.refreshUI()
        }
    }

    func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    func refreshUI() {
        let player = musicPlayer.player
        let entry = player.queue.currentEntry
        let artworkURL = entry?.artwork?.url(width: 1000, height: 1000)

        titleLabel.text = entry?.title ?? "재생 중인 음악이 없습니다"
        artistLabel.text = entry?.subtitle ?? ""
        queueHeaderTitle.text = entry?.title ?? "재생 중인 음악이 없습니다"
        queueHeaderArtist.text = entry?.subtitle ?? ""

        if artworkURL != lastArtworkURL {
            lastArtworkURL = artworkURL
            artworkImageView.kf.setImage(with: artworkURL)
            queueHeaderArtwork.kf.setImage(with: artworkURL)
            backgroundImageView.kf.setImage(with: artworkURL)
        }

        let duration = duration(of: entry)
        let elapsed = min(player.playbackTime, max(duration, 0))
        progressSlider.maximumValue = Float(max(duration, 1))
        if !progressSlider.isTracking {
            progressSlider.value = Float(elapsed)
        }
        elapsedLabel.text = timeText(elapsed)
        remainingLabel.text = "−\(timeText(max(duration - elapsed, 0)))"

        let playImage = player.state.playbackStatus == .playing
            ? "pause.fill"
            : "play.fill"
        playPauseButton.setImage(
            UIImage(
                systemName: playImage,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 58)
            ),
            for: .normal
        )

        refreshQueueModeButtons()
        rebuildQueue(entries: Array(player.queue.entries), currentEntry: entry)
    }

    func rebuildQueue(
        entries: [ApplicationMusicPlayer.Queue.Entry],
        currentEntry: ApplicationMusicPlayer.Queue.Entry?
    ) {
        for view in queueStackView.arrangedSubviews {
            queueStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        guard !entries.isEmpty else {
            let emptyLabel = Self.makeLabel(
                font: .preferredFont(forTextStyle: .body),
                color: UIColor.white.withAlphaComponent(0.65),
                alignment: .center,
                lines: 1
            )
            emptyLabel.text = "재생 대기열이 비어 있습니다."
            queueStackView.addArrangedSubview(emptyLabel)
            return
        }

        let currentIndex = entries.firstIndex { $0.id == currentEntry?.id } ?? 0
        let upcomingEntries = Array(entries.dropFirst(currentIndex + 1))
        continueLabel.text = upcomingEntries.isEmpty ? "재생 목록" : "계속 재생"

        let displayEntries = upcomingEntries.isEmpty ? entries : upcomingEntries
        for entry in displayEntries {
            queueStackView.addArrangedSubview(makeQueueRow(entry))
        }
    }

    func makeQueueRow(_ entry: ApplicationMusicPlayer.Queue.Entry) -> UIView {
        let artwork = UIImageView()
        artwork.contentMode = .scaleAspectFill
        artwork.clipsToBounds = true
        artwork.layer.cornerRadius = 8
        artwork.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        artwork.translatesAutoresizingMaskIntoConstraints = false
        artwork.kf.setImage(with: entry.artwork?.url(width: 240, height: 240))

        let title = Self.makeLabel(
            font: .preferredFont(forTextStyle: .body),
            color: .white,
            alignment: .left,
            lines: 1
        )
        title.text = entry.title

        let artist = Self.makeLabel(
            font: .preferredFont(forTextStyle: .subheadline),
            color: UIColor.white.withAlphaComponent(0.68),
            alignment: .left,
            lines: 1
        )
        artist.text = entry.subtitle

        let textStack = UIStackView(arrangedSubviews: [title, artist])
        textStack.axis = .vertical
        textStack.spacing = 3

        let handle = UIImageView(image: UIImage(systemName: "line.3.horizontal"))
        handle.tintColor = UIColor.white.withAlphaComponent(0.45)

        let row = UIStackView(arrangedSubviews: [artwork, textStack, handle])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12

        NSLayoutConstraint.activate([
            artwork.widthAnchor.constraint(equalToConstant: 56),
            artwork.heightAnchor.constraint(equalToConstant: 56),
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 64)
        ])
        return row
    }

    func refreshQueueModeButtons() {
        let state = musicPlayer.player.state
        let shuffleEnabled = state.shuffleMode == .songs
        let repeatEnabled = state.repeatMode == .all || state.repeatMode == .one

        shuffleModeButton.configuration?.baseBackgroundColor = shuffleEnabled
            ? UIColor.white
            : UIColor.white.withAlphaComponent(0.15)
        shuffleModeButton.configuration?.baseForegroundColor = shuffleEnabled
            ? UIColor.darkGray
            : UIColor.white

        repeatModeButton.configuration?.baseBackgroundColor = repeatEnabled
            ? UIColor.white
            : UIColor.white.withAlphaComponent(0.15)
        repeatModeButton.configuration?.baseForegroundColor = repeatEnabled
            ? UIColor.darkGray
            : UIColor.white
    }

    func duration(of entry: ApplicationMusicPlayer.Queue.Entry?) -> TimeInterval {
        guard let item = entry?.item else { return 0 }
        switch item {
        case .song(let song):
            return song.duration ?? 0
        case .musicVideo(let video):
            return video.duration ?? 0
        @unknown default:
            return 0
        }
    }

    func timeText(_ value: TimeInterval) -> String {
        let seconds = max(Int(value), 0)
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

// MARK: - Actions
private extension TestMusicPlayerViewController {

    func configureActions() {
        progressSlider.addTarget(
            self,
            action: #selector(didChangeProgress),
            for: .valueChanged
        )
    }

    @objc func didChangeMode() {
        let showsPlayer = modeControl.selectedSegmentIndex == 0
        playerContentView.isHidden = !showsPlayer
        queueContentView.isHidden = showsPlayer
    }

    @objc func didTapPrevious() {
        performPlayerTask { try await self.musicPlayer.skipToPrevious() }
    }

    @objc func didTapPlayPause() {
        performPlayerTask { try await self.musicPlayer.togglePlayPause() }
    }

    @objc func didTapNext() {
        performPlayerTask { try await self.musicPlayer.skipToNext() }
    }

    @objc func didChangeProgress() {
        musicPlayer.player.playbackTime = TimeInterval(progressSlider.value)
    }

    @objc func didTapShuffleMode() {
        let state = musicPlayer.player.state
        state.shuffleMode = state.shuffleMode == .songs ? .off : .songs
        refreshQueueModeButtons()
    }

    @objc func didTapRepeatMode() {
        let state = musicPlayer.player.state
        switch state.repeatMode {
        case .all:
            state.repeatMode = .one
        case .one:
            state.repeatMode = .none
        default:
            state.repeatMode = .all
        }
        refreshQueueModeButtons()
    }

    func performPlayerTask(
        operation: @escaping @MainActor () async throws -> Void
    ) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await operation()
                refreshUI()
            } catch {
                let alert = UIAlertController(
                    title: "재생 오류",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                present(alert, animated: true)
            }
        }
    }
}

// MARK: - View Factory
private extension TestMusicPlayerViewController {

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

    func makeControlButton(
        systemName: String,
        pointSize: CGFloat,
        action: Selector
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(
            UIImage(
                systemName: systemName,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize)
            ),
            for: .normal
        )
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    func makeQueueModeButton(
        systemName: String,
        action: Selector?
    ) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: systemName)
        configuration.baseForegroundColor = .white
        configuration.baseBackgroundColor = UIColor.white.withAlphaComponent(0.15)
        configuration.cornerStyle = .capsule

        let button = UIButton(configuration: configuration)
        if let action {
            button.addTarget(self, action: action, for: .touchUpInside)
        }
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return button
    }
}

// MARK: - Layout
private extension TestMusicPlayerViewController {

    func setLayout() {
        view.addSubview(backgroundImageView)
        view.addSubview(blurView)
        view.addSubview(dimView)
        view.addSubview(modeControl)
        view.addSubview(playerContentView)
        view.addSubview(queueContentView)

        playerContentView.translatesAutoresizingMaskIntoConstraints = false
        queueContentView.translatesAutoresizingMaskIntoConstraints = false
        playerContentView.addSubview(playerStack)
        queueContentView.addSubview(queuePageStack)
        queueScrollView.addSubview(queueStackView)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            modeControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            modeControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modeControl.widthAnchor.constraint(equalToConstant: 230),

            playerContentView.topAnchor.constraint(equalTo: modeControl.bottomAnchor, constant: 18),
            playerContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerContentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            queueContentView.topAnchor.constraint(equalTo: modeControl.bottomAnchor, constant: 18),
            queueContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            queueContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            queueContentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            playerStack.topAnchor.constraint(equalTo: playerContentView.topAnchor),
            playerStack.leadingAnchor.constraint(equalTo: playerContentView.leadingAnchor, constant: 34),
            playerStack.trailingAnchor.constraint(equalTo: playerContentView.trailingAnchor, constant: -34),
            playerStack.bottomAnchor.constraint(lessThanOrEqualTo: playerContentView.bottomAnchor, constant: -18),
            artworkImageView.heightAnchor.constraint(equalTo: artworkImageView.widthAnchor),
            playbackControlStack.heightAnchor.constraint(equalToConstant: 70),
            volumeView.heightAnchor.constraint(equalToConstant: 36),

            queuePageStack.topAnchor.constraint(equalTo: queueContentView.topAnchor),
            queuePageStack.leadingAnchor.constraint(equalTo: queueContentView.leadingAnchor, constant: 28),
            queuePageStack.trailingAnchor.constraint(equalTo: queueContentView.trailingAnchor, constant: -28),
            queuePageStack.bottomAnchor.constraint(equalTo: queueContentView.bottomAnchor, constant: -12),

            queueHeaderArtwork.widthAnchor.constraint(equalToConstant: 76),
            queueHeaderArtwork.heightAnchor.constraint(equalToConstant: 76),
            queueScrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 220),

            queueStackView.topAnchor.constraint(equalTo: queueScrollView.contentLayoutGuide.topAnchor),
            queueStackView.leadingAnchor.constraint(equalTo: queueScrollView.contentLayoutGuide.leadingAnchor),
            queueStackView.trailingAnchor.constraint(equalTo: queueScrollView.contentLayoutGuide.trailingAnchor),
            queueStackView.bottomAnchor.constraint(equalTo: queueScrollView.contentLayoutGuide.bottomAnchor),
            queueStackView.widthAnchor.constraint(equalTo: queueScrollView.frameLayoutGuide.widthAnchor)
        ])
    }
}
