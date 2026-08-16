//
//  TestMusicPlayer.swift
//  flover9
//

import MusicKit

/// 테스트용 앨범 상세 화면과 플레이어 화면이 같은 재생 상태를 공유하도록 합니다.
///
/// 실제 재생은 MusicKit이 제공하는 `ApplicationMusicPlayer.shared`가 담당하며,
/// 이 객체는 두 테스트 뷰컨트롤러에서 사용하는 편의 함수를 한곳에 모읍니다.
@MainActor
final class TestMusicPlayer {

    /// 앱 전체에서 하나만 사용하는 테스트 플레이어 객체입니다.
    static let shared = TestMusicPlayer()

    /// Apple Music 앱과 별개로 flover9 앱 안에서 음악을 재생하는 플레이어입니다.
    let player = ApplicationMusicPlayer.shared

    private init() {}

    /// 전달받은 앨범의 수록곡으로 기존 큐를 교체하고 정순으로 바로 재생합니다.
    func play(album: Album) async throws {
        let tracks = album.tracks.map { Array($0) } ?? []
        guard !tracks.isEmpty else { return }

        player.state.shuffleMode = .off
        player.queue = ApplicationMusicPlayer.Queue(for: tracks)
        try await player.play()
    }

    /// 기존 큐를 비우고 앨범 수록곡을 무작위 순서로 넣어 바로 재생합니다.
    func shufflePlay(album: Album) async throws {
        let tracks = album.tracks.map { Array($0) } ?? []
        let shuffledTracks = tracks.shuffled()
        guard !shuffledTracks.isEmpty else { return }

        // 이미 배열 순서를 섞었으므로 플레이어 자체 셔플은 끕니다.
        player.state.shuffleMode = .off
        player.queue = ApplicationMusicPlayer.Queue(for: shuffledTracks)
        try await player.play()
    }

    /// 전달받은 앨범의 특정 곡부터 재생합니다.
    func play(album: Album, startingAt track: Track) async throws {
        player.queue = ApplicationMusicPlayer.Queue(
            album: album,
            startingAt: track
        )
        try await player.play()
    }

    /// 현재 큐의 마지막에 앨범 수록곡을 앨범 순서대로 추가합니다.
    func addToQueue(album: Album) async throws {
        let tracks = album.tracks.map { Array($0) } ?? []
        guard !tracks.isEmpty else { return }

        try await player.queue.insert(tracks, position: .tail)
    }

    /// 현재 상태에 따라 음악을 재생하거나 일시 정지합니다.
    func togglePlayPause() async throws {
        if player.state.playbackStatus == .playing {
            player.pause()
        } else {
            try await player.play()
        }
    }

    /// 재생 큐의 이전 곡으로 이동합니다.
    func skipToPrevious() async throws {
        try await player.skipToPreviousEntry()
    }

    /// 재생 큐의 다음 곡으로 이동합니다.
    func skipToNext() async throws {
        try await player.skipToNextEntry()
    }
}
