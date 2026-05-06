import Foundation

public struct PlaybackSession {
    public let mediaItemId: UUID
    public var position: TimeInterval
    public var duration: TimeInterval
    public var isPlaying: Bool
    public var selectedAudioTrackIndex: Int?
    public var selectedSubtitleTrackIndex: Int?
    public var subtitleOffset: TimeInterval
    public var playbackRate: Float
    public var chapterIndex: Int?
    public var lastResumedAt: Date

    public init(
        mediaItemId: UUID,
        position: TimeInterval = 0,
        duration: TimeInterval = 0,
        isPlaying: Bool = false,
        selectedAudioTrackIndex: Int? = nil,
        selectedSubtitleTrackIndex: Int? = nil,
        subtitleOffset: TimeInterval = 0,
        playbackRate: Float = 1.0,
        chapterIndex: Int? = nil,
        lastResumedAt: Date = Date()
    ) {
        self.mediaItemId = mediaItemId
        self.position = position
        self.duration = duration
        self.isPlaying = isPlaying
        self.selectedAudioTrackIndex = selectedAudioTrackIndex
        self.selectedSubtitleTrackIndex = selectedSubtitleTrackIndex
        self.subtitleOffset = subtitleOffset
        self.playbackRate = playbackRate
        self.chapterIndex = chapterIndex
        self.lastResumedAt = lastResumedAt
    }
}
