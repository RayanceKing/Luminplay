import LuminplayCore
import MediaPlayer

final class NowPlayingInfo {
    private var isActive = false

    func startSession(for item: MediaItem, duration: TimeInterval, position: TimeInterval = 0) {
        let center = MPNowPlayingInfoCenter.default()
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: item.title,
            MPMediaItemPropertyArtist: item.subtitle,
            MPNowPlayingInfoPropertyMediaType: 2, // MPMediaType.movie
            MPNowPlayingInfoPropertyPlaybackRate: 1.0,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: position
        ]
        center.nowPlayingInfo = info
        isActive = true
        setupRemoteCommands()
    }

    func updatePosition(_ position: TimeInterval, duration: TimeInterval) {
        guard isActive else { return }
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = position
        info[MPMediaItemPropertyPlaybackDuration] = duration
        info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    func updatePlaybackState(isPlaying: Bool) {
        guard isActive else { return }
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    func stop() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        isActive = false
    }

    private func setupRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.addTarget { [weak self] _ in
            self?.updatePlaybackState(isPlaying: true)
            return .success
        }

        center.pauseCommand.addTarget { [weak self] _ in
            self?.updatePlaybackState(isPlaying: false)
            return .success
        }

        center.skipForwardCommand.preferredIntervals = [10, 15, 30]
        center.skipForwardCommand.addTarget { _ in .success }

        center.skipBackwardCommand.preferredIntervals = [10, 15, 30]
        center.skipBackwardCommand.addTarget { _ in .success }

        center.changePlaybackPositionCommand.addTarget { event in
            guard let e = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = e.positionTime
            return .success
        }
    }

    deinit {
        stop()
    }
}
