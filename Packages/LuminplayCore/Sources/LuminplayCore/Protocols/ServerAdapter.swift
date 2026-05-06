import Foundation

public protocol ServerAdapter: LibraryProviding, Sendable {
    var connection: ServerConnection { get }
    var isAuthenticated: Bool { get }
    func connect() async throws
    func disconnect()
    func authenticate(username: String, password: String) async throws
    func fetchStreamURL(for item: MediaItem) async throws -> URL
    func fetchSubtitles(for item: MediaItem) async throws -> [SubtitleTrack]
    func fetchAudioTracks(for item: MediaItem) async throws -> [AudioTrack]
    func reportPlaybackProgress(itemId: UUID, position: TimeInterval) async throws
}
