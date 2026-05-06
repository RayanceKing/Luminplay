import AVKit
import LuminplayCore
import SwiftUI

struct PlayerView: View {
    @StateObject private var sessionManager: PlaybackSessionManager
    @State private var showControls = true
    @State private var showChapterList = false
    @State private var hideControlsTask: Task<Void, Never>?
    @State private var player: AVPlayer?
    @State private var backend: AVPlayerBackend?

    private let item: MediaItem
    private let streamURL: URL
    private let nowPlaying = NowPlayingInfo()
    private var onDismiss: () -> Void

    init(
        item: MediaItem,
        streamURL: URL,
        sessionManager: PlaybackSessionManager = PlaybackSessionManager(),
        onDismiss: @escaping () -> Void = {}
    ) {
        self.item = item
        self.streamURL = streamURL
        self._sessionManager = StateObject(wrappedValue: sessionManager)
        self.onDismiss = onDismiss
    }

    var body: some View {
        GeometryReader { _ in
            ZStack {
                Color.black.ignoresSafeArea()

                if let player = player {
                    VideoPlayer(player: player)
                        .ignoresSafeArea()
                        .onTapGesture { toggleControls() }

                    SubtitleOverlay(
                        cues: sessionManager.subtitleCues,
                        position: backend?.currentPosition ?? 0,
                        offset: sessionManager.session?.subtitleOffset ?? 0
                    )

                    if showControls, let backend = backend {
                        TransportControls(
                            isPlaying: backend.isPlaying,
                            position: backend.currentPosition,
                            duration: backend.duration,
                            playbackRate: backend.rate,
                            audioTracks: sessionManager.availableAudioTracks,
                            subtitleTracks: sessionManager.availableSubtitles,
                            chapters: sessionManager.availableChapters,
                            selectedAudioIndex: sessionManager.selectedAudioTrackIndex,
                            selectedSubtitleIndex: sessionManager.selectedSubtitleTrackIndex,
                            onPlayPause: {
                                if backend.isPlaying { backend.pause() } else { backend.play() }
                                showControlsTemporarily()
                            },
                            onSeek: { backend.seek(to: $0) },
                            onSkipForward: { backend.skipForward(10) },
                            onSkipBackward: { backend.skipBackward(10) },
                            onSelectAudio: { sessionManager.selectAudioTrack($0) },
                            onSelectSubtitle: { index in sessionManager.selectSubtitleTrack(index) },
                            onSelectRate: { backend.rate = $0 },
                            onSelectChapter: { _ in withAnimation { showChapterList.toggle() } }
                        )
                    }

                    if showChapterList {
                        ChapterOverlay(
                            chapters: sessionManager.availableChapters,
                            currentPosition: backend?.currentPosition ?? 0,
                            onSelectChapter: { chapter in
                                backend?.seek(to: chapter.startTime)
                                withAnimation { showChapterList = false }
                            }
                        )
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                } else {
                    ProgressView().scaleEffect(1.5).tint(.white)
                }
            }
            .overlay(alignment: .topLeading) {
                Button {
                    backend?.stop()
                    sessionManager.stop()
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(20)
                }
                .buttonStyle(.plain)
                .opacity(showControls ? 1 : 0)
            }
        }
        .onAppear { setupBackend(); showControlsTemporarily() }
        .onDisappear {
            hideControlsTask?.cancel()
            backend?.pause()
            sessionManager.pause()
            nowPlaying.stop()
        }
    }

    private func setupBackend() {
        sessionManager.beginSession(for: item)
        let be = AVPlayerBackend(session: sessionManager.session!)

        be.setPositionCallback { pos in
            sessionManager.updatePosition(pos)
            nowPlaying.updatePosition(pos, duration: be.duration)
        }
        be.setDurationCallback { dur in sessionManager.setDuration(dur) }
        be.setPlaybackStateCallback { playing in nowPlaying.updatePlaybackState(isPlaying: playing) }

        Task {
            try? await be.load(url: streamURL)
            be.play()
            player = be.avPlayer
            backend = be
        }
        nowPlaying.startSession(for: item, duration: 0)
    }

    private func toggleControls() {
        withAnimation(.easeInOut(duration: 0.25)) { showControls.toggle() }
        if showControls { showControlsTemporarily() }
    }

    private func showControlsTemporarily() {
        hideControlsTask?.cancel()
        showControls = true
        hideControlsTask = Task {
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.3)) { showControls = false }
        }
    }
}
