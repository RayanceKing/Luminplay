import Foundation

public protocol SyncProviding: Sendable {
    func syncPlaybackState(_ session: PlaybackSession)
    func fetchPlaybackState(for itemId: UUID) async throws -> PlaybackSession?
    func fetchUserData() async throws -> UserSyncData
}
