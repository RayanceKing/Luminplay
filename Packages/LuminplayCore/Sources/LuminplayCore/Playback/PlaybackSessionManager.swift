import Foundation

public final class PlaybackSessionManager: ObservableObject {
    @Published public private(set) var session: PlaybackSession?
    @Published public var availableAudioTracks: [AudioTrack] = []
    @Published public var availableSubtitles: [SubtitleTrack] = []
    @Published public var availableChapters: [Chapter] = []
    @Published public var subtitleCues: [SubtitleCue] = []
    @Published public var selectedAudioTrackIndex: Int?
    @Published public var selectedSubtitleTrackIndex: Int?

    private let userDefaultsKey = "com.luminplay.playbackSessions"

    public init() {}

    public func beginSession(for item: MediaItem, duration: TimeInterval = 0) {
        let persisted = loadPersistedPosition(for: item.id)
        session = PlaybackSession(
            mediaItemId: item.id,
            position: persisted.position,
            duration: duration,
            isPlaying: true,
            selectedAudioTrackIndex: persisted.audioTrackIndex,
            selectedSubtitleTrackIndex: persisted.subtitleTrackIndex,
            subtitleOffset: persisted.subtitleOffset,
            lastResumedAt: Date()
        )
    }

    public func updatePosition(_ position: TimeInterval) {
        session?.position = position
        session?.lastResumedAt = Date()
    }

    public func play() {
        session?.isPlaying = true
    }

    public func pause() {
        session?.isPlaying = false
        persistCurrentSession()
    }

    public func stop() {
        persistCurrentSession()
        session = nil
        subtitleCues = []
    }

    public func seek(to position: TimeInterval) {
        session?.position = position
        updateActiveChapter(for: position)
    }

    public func setPlaybackRate(_ rate: Float) {
        session?.playbackRate = rate
    }

    public func selectAudioTrack(_ index: Int) {
        session?.selectedAudioTrackIndex = index
        selectedAudioTrackIndex = index
    }

    public func selectSubtitleTrack(_ index: Int?) {
        session?.selectedSubtitleTrackIndex = index
        selectedSubtitleTrackIndex = index
    }

    public func setDuration(_ duration: TimeInterval) {
        session?.duration = duration
    }

    public func setSubtitleOffset(_ offset: TimeInterval) {
        session?.subtitleOffset = offset
    }

    public func skipForward(_ seconds: TimeInterval = 10) {
        guard let s = session else { return }
        session?.position = min(s.position + seconds, s.duration)
        updateActiveChapter(for: session?.position ?? 0)
    }

    public func skipBackward(_ seconds: TimeInterval = 10) {
        guard let s = session else { return }
        session?.position = max(s.position - seconds, 0)
        updateActiveChapter(for: session?.position ?? 0)
    }

    public func loadChapters(_ chapters: [Chapter]) {
        availableChapters = chapters
    }

    public func loadSubtitles(_ cues: [SubtitleCue]) {
        subtitleCues = cues
    }

    // MARK: - Persistence

    private func persistCurrentSession() {
        guard let s = session else { return }
        var sessions = loadSessions()
        let entry = PersistedSession(
            mediaItemId: s.mediaItemId,
            position: s.position,
            audioTrackIndex: s.selectedAudioTrackIndex,
            subtitleTrackIndex: s.selectedSubtitleTrackIndex,
            subtitleOffset: s.subtitleOffset,
            lastResumedAt: s.lastResumedAt
        )
        sessions[s.mediaItemId] = entry
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    private func loadPersistedPosition(for itemId: UUID) -> PersistedSession {
        let sessions = loadSessions()
        return sessions[itemId] ?? PersistedSession(mediaItemId: itemId, position: 0, subtitleOffset: 0, lastResumedAt: Date())
    }

    private func loadSessions() -> [UUID: PersistedSession] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let sessions = try? JSONDecoder().decode([UUID: PersistedSession].self, from: data) else {
            return [:]
        }
        return sessions
    }

    private func updateActiveChapter(for position: TimeInterval) {
        guard let idx = availableChapters.firstIndex(where: {
            position >= $0.startTime && position < $0.endTime
        }) else {
            session?.chapterIndex = nil
            return
        }
        session?.chapterIndex = idx
    }
}

public struct SubtitleCue: Identifiable, Hashable {
    public let id = UUID()
    public let start: TimeInterval
    public let end: TimeInterval
    public let text: String

    public init(start: TimeInterval, end: TimeInterval, text: String) {
        self.start = start
        self.end = end
        self.text = text
    }
}

private struct PersistedSession: Codable {
    let mediaItemId: UUID
    var position: TimeInterval
    var audioTrackIndex: Int?
    var subtitleTrackIndex: Int?
    var subtitleOffset: TimeInterval
    var lastResumedAt: Date
}
