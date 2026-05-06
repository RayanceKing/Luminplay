import Foundation

public protocol PlayerBackend: AnyObject, Sendable {
    var session: PlaybackSession { get }
    var currentPosition: TimeInterval { get }
    var duration: TimeInterval { get }
    var isPlaying: Bool { get }
    var rate: Float { get set }

    func load(url: URL) async throws
    func play()
    func pause()
    func seek(to: TimeInterval)
    func skipForward(_ seconds: TimeInterval)
    func skipBackward(_ seconds: TimeInterval)
    func stop()

    func selectAudioTrack(_ track: AudioTrack)
    func selectSubtitleTrack(_ track: SubtitleTrack?)
    func setSubtitleCues(_ cues: [SubtitleCue])

    func setPositionCallback(_ callback: @escaping @Sendable (TimeInterval) -> Void)
    func setDurationCallback(_ callback: @escaping @Sendable (TimeInterval) -> Void)
    func setPlaybackStateCallback(_ callback: @escaping @Sendable (Bool) -> Void)
}
