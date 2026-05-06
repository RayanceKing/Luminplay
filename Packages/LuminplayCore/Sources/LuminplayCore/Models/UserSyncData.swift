import Foundation

public struct UserSyncData: Codable {
    public var watchHistory: [WatchEntry]
    public var favorites: [UUID]
    public var serverConnections: [ServerConnection]

    public init(
        watchHistory: [WatchEntry] = [],
        favorites: [UUID] = [],
        serverConnections: [ServerConnection] = []
    ) {
        self.watchHistory = watchHistory
        self.favorites = favorites
        self.serverConnections = serverConnections
    }
}

public struct WatchEntry: Codable {
    public let mediaItemId: UUID
    public var position: TimeInterval
    public var completed: Bool
    public var lastWatched: Date

    public init(
        mediaItemId: UUID,
        position: TimeInterval = 0,
        completed: Bool = false,
        lastWatched: Date = Date()
    ) {
        self.mediaItemId = mediaItemId
        self.position = position
        self.completed = completed
        self.lastWatched = lastWatched
    }
}
