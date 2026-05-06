import AVKit
import Combine
import LuminplayCore

final class AVPlayerBackend: PlayerBackend {
    let session: PlaybackSession
    var currentPosition: TimeInterval { _position }
    var duration: TimeInterval { _duration }
    var isPlaying: Bool { _isPlaying }
    var rate: Float {
        get { player?.rate ?? 1.0 }
        set { player?.rate = newValue }
    }

    var avPlayer: AVPlayer? { player }
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    private var _position: TimeInterval = 0
    private var _duration: TimeInterval = 0
    private var _isPlaying = false

    private var positionCallback: (@Sendable (TimeInterval) -> Void)?
    private var durationCallback: (@Sendable (TimeInterval) -> Void)?
    private var stateCallback: (@Sendable (Bool) -> Void)?

    init(session: PlaybackSession) {
        self.session = session
    }

    func load(url: URL) async throws {
        let avp = AVPlayer(url: url)
        player = avp

        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = avp.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            let pos = time.seconds
            _position = pos
            positionCallback?(pos)

            if let itemDuration = avp.currentItem?.duration.seconds, itemDuration > 0 {
                _duration = itemDuration
                durationCallback?(itemDuration)
            }
        }

        statusObserver = avp.currentItem?.observe(\.status) { [weak self] item, _ in
            guard let self else { return }
            if item.status == .readyToPlay {
                _duration = item.duration.seconds
                durationCallback?(_duration)
            }
        }
    }

    func play() {
        player?.play()
        _isPlaying = true
        stateCallback?(true)
    }

    func pause() {
        player?.pause()
        _isPlaying = false
        stateCallback?(false)
    }

    func seek(to position: TimeInterval) {
        let time = CMTime(seconds: position, preferredTimescale: 600)
        player?.seek(to: time)
        _position = position
    }

    func skipForward(_ seconds: TimeInterval) {
        let newPos = min(_position + seconds, _duration)
        seek(to: newPos)
    }

    func skipBackward(_ seconds: TimeInterval) {
        let newPos = max(_position - seconds, 0)
        seek(to: newPos)
    }

    func stop() {
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        timeObserver = nil
        statusObserver = nil
        player = nil
        _isPlaying = false
        stateCallback?(false)
    }

    func selectAudioTrack(_ track: AudioTrack) {}
    func selectSubtitleTrack(_ track: SubtitleTrack?) {}
    func setSubtitleCues(_ cues: [SubtitleCue]) {}

    func setPositionCallback(_ callback: @escaping @Sendable (TimeInterval) -> Void) { positionCallback = callback }
    func setDurationCallback(_ callback: @escaping @Sendable (TimeInterval) -> Void) { durationCallback = callback }
    func setPlaybackStateCallback(_ callback: @escaping @Sendable (Bool) -> Void) { stateCallback = callback }

    deinit {
        stop()
    }
}
