//
//  HeroView.swift
//  flover9
//
//  Created by 박선린 on 8/17/26.
//
import UIKit
import AVFoundation
import SnapKit

final class HeroView: UIView {

    // MARK: - UI

    /// 영상을 표시하는 영역
    private let videoView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()

    /// 영상 아래쪽을 자연스럽게 연결하는 Gradient
    private let gradientView = HeroGradientView()

    /// 멤버 프로필 영역
    private let memberStackView: UIStackView = {
        let stackView = UIStackView()

        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fillEqually
        stackView.spacing = 8

        return stackView
    }()


    // MARK: - Player

    private let player = AVQueuePlayer()
    private let playerLayer = AVPlayerLayer()

    private var playerLooper: AVPlayerLooper?

    // MARK: - Properties
    private var introItem: AVPlayerItem?

    var didtapMember: ((MemberEntity) -> Void)?

    private var isAppActive = UIApplication.shared.applicationState == .active
    private var isVisible = false


    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setLayout()
        setupAudioSession()
        setPlayer()
        addObserver()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        // AVPlayerLayer는 Auto Layout을 지원하지 않음
        // 따라서 직접 frame 지정
        playerLayer.frame = videoView.bounds
    }


    private func setLayout() {

        addSubview(videoView)
        addSubview(gradientView)
        addSubview(memberStackView)

        // MARK: Video

        videoView.snp.makeConstraints {

            $0.top.leading.trailing.equalToSuperview()

            // 영상 원본 비율 16:9
            //
            // width : height
            // 16 : 9
            //
            // width * 9 / 16
            $0.height
                .equalTo(videoView.snp.width)
                .multipliedBy(9.0 / 16.0)
        }

        // MARK: Gradient

        gradientView.snp.makeConstraints {

            $0.leading.trailing.equalToSuperview()

            $0.top.bottom.equalTo(videoView)
        }


        // MARK: Members
        memberStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)

            $0.top.equalTo(videoView.snp.bottom)
                .offset(-50)

            $0.height.equalTo(110)
        }
    }


    // MARK: - Player
    private func setPlayer() {
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill

        videoView.layer.addSublayer(playerLayer)

        player.isMuted = true
    }

    // MARK: - Audio Setting
    func setupAudioSession() {
//        do {
//            let session = AVAudioSession.sharedInstance()
//            // .playback: 다른 오디오를 백그라운드로 보내거나 무시하고 내 소리를 재생
//            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
//            try session.setActive(true)
//        } catch {
//            print("Audio Session 설정 실패: \(error.localizedDescription)")
//        }
    }

    // MARK: - Configure
    func configure(
        introURL: URL,
        loopURL: URL,
        members: [MemberEntity]
    ) {
        configureMembers(members)

        resetPlayer()

        let introItem = AVPlayerItem(url: introURL)
        let loopItem = AVPlayerItem(url: loopURL)

        self.introItem = introItem

        // 1. Intro를 먼저 큐에 삽입
        player.insert(introItem, after: nil)

        // 2. Intro 뒤에 Loop가 무한 반복되도록 구성
        playerLooper = AVPlayerLooper(
            player: player,
            templateItem: loopItem,
            timeRange: .invalid,
            existingItemsOrdering: .loopingItemsFollowExistingItems
        )

        player.play()
    }


    private func configureMembers(
        _ members: [MemberEntity]
    ) {

        memberStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }


        members.forEach { member in

            let view = HeroMemberView()

            view.configure(
                member: member
            )

            view.addAction( UIAction(handler: { [weak self] _ in
                guard let self else { return }
                // 멤버 클릭
                self.didtapMember?(member)

            }), for: .touchUpInside)

            memberStackView.addArrangedSubview(view)
        }
    }


    // MARK: - Control

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }


    func stop() {
        player.pause()

        playerLooper?.disableLooping()
        playerLooper = nil

        player.removeAllItems()

        introItem = nil
    }

    private func resetPlayer() {
        player.pause()

        playerLooper?.disableLooping()
        playerLooper = nil

        player.removeAllItems()

        introItem = nil
    }

    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePlayback),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }


    @objc
    private func updatePlayback() {
        guard isAppActive, isVisible, player.currentItem != nil else {
            player.pause()
            return
        }

        player.play()
    }
}
