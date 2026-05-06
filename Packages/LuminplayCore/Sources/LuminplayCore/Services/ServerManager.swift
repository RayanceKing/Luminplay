import Foundation

public final class ServerManager: ObservableObject, @unchecked Sendable {
    @Published public private(set) var connections: [ServerConnection] = []
    @Published public private(set) var activeAdapter: (any ServerAdapter)?

    private var adapters: [UUID: any ServerAdapter] = [:]

    public init() {}

    public func addConnection(_ connection: ServerConnection) {
        connections.append(connection)
        let adapter = makeAdapter(for: connection)
        adapters[connection.id] = adapter
    }

    public func removeConnection(id: UUID) {
        connections.removeAll { $0.id == id }
        adapters[id]?.disconnect()
        adapters.removeValue(forKey: id)
        if activeAdapter?.connection.id == id {
            activeAdapter = adapters.values.first
        }
    }

    public func connect(to id: UUID) async throws {
        guard let adapter = adapters[id] else { return }
        try await adapter.connect()
        activeAdapter = adapter
        if let idx = connections.firstIndex(where: { $0.id == id }) {
            connections[idx].isConnected = true
        }
    }

    public func disconnect(from id: UUID) {
        adapters[id]?.disconnect()
        if let idx = connections.firstIndex(where: { $0.id == id }) {
            connections[idx].isConnected = false
        }
        if activeAdapter?.connection.id == id {
            activeAdapter = nil
        }
    }

    public func authenticate(id: UUID, username: String, password: String) async throws {
        guard let adapter = adapters[id] else { return }
        try await adapter.authenticate(username: username, password: password)
        activeAdapter = adapter
        if let idx = connections.firstIndex(where: { $0.id == id }) {
            connections[idx].isConnected = true
        }
    }

    public func adapter(for id: UUID) -> (any ServerAdapter)? {
        adapters[id]
    }

    private func makeAdapter(for connection: ServerConnection) -> any ServerAdapter {
        switch connection.kind {
        case .jellyfin: return JellyfinAdapter(connection: connection)
        case .emby: return EmbyAdapter(connection: connection)
        case .plex: return PlexAdapter(connection: connection)
        case .smb: return SMBAdapter(connection: connection)
        case .webdav: return WebDAVAdapter(connection: connection)
        }
    }
}
