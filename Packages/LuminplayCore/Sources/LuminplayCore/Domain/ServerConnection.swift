import Foundation

public enum ServerKind: String, CaseIterable, Codable, Sendable {
    case jellyfin
    case emby
    case plex
    case webdav
    case smb
}

public struct ServerConnection: Identifiable, Codable {
    public let id: UUID
    public var label: String
    public var kind: ServerKind
    public var baseURL: URL
    public var username: String?
    public var apiKey: String?
    public var isConnected: Bool

    public init(
        id: UUID = UUID(),
        label: String,
        kind: ServerKind,
        baseURL: URL,
        username: String? = nil,
        apiKey: String? = nil,
        isConnected: Bool = false
    ) {
        self.id = id
        self.label = label
        self.kind = kind
        self.baseURL = baseURL
        self.username = username
        self.apiKey = apiKey
        self.isConnected = isConnected
    }
}
