import Foundation

@MainActor
public protocol PlaybackEngine {
    func play(_ item: MediaItem)
    func pause()
    func resume()
    func seek(to: TimeInterval)
    func toggleFavorite(_ item: MediaItem)
    func setAudioTrack(_ index: Int)
    func setSubtitleTrack(_ index: Int?)
    func setPlaybackRate(_ rate: Float)
    func skipForward(_ seconds: TimeInterval)
    func skipBackward(_ seconds: TimeInterval)
}
