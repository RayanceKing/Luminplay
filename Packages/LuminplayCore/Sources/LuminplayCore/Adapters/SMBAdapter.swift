import Foundation
import UniformTypeIdentifiers

public final class SMBAdapter: ServerAdapter, @unchecked Sendable {
    public let connection: ServerConnection
    public let isAuthenticated: Bool = true

    private let videoExtensions: Set<String> = [
        "mkv", "mp4", "m4v", "mov", "avi", "wmv", "flv", "webm", "ts", "m2ts", "iso"
    ]

    private let subtitleExtensions: Set<String> = [
        "srt", "vtt", "ass", "ssa", "sub", "idx"
    ]

    public init(connection: ServerConnection) {
        self.connection = connection
    }

    public func connect() async throws {}
    public func disconnect() {}

    public func authenticate(username: String, password: String) async throws {}

    // MARK: - LibraryProviding

    public var heroItems: [MediaItem] { _cachedHeroItems }
    public var featured: MediaItem { _cachedHeroItems.first ?? _placeholderItem }
    public var continueWatching: [MediaItem] { _cachedContinueWatching }
    public var recentlyAdded: [MediaItem] { _cachedRecentlyAdded }
    public var collections: [MediaItem] { _cachedCollections }

    private var _cachedHeroItems: [MediaItem] = []
    private var _cachedContinueWatching: [MediaItem] = []
    private var _cachedRecentlyAdded: [MediaItem] = []
    private var _cachedCollections: [MediaItem] = []

    private var _placeholderItem: MediaItem {
        MediaItem(
            title: "No Media Found", subtitle: "", overview: "",
            durationText: "", progress: 0, year: "", genres: [],
            accent: .cobalt, artworkSymbol: "tv.fill", resolution: "",
            audio: "", heroBadge: "", contentType: "", rating: "",
            heroChromeStyle: .dark, heroArtworkStyle: .aurora
        )
    }

    public func fetchHeroItems() async throws -> [MediaItem] {
        let items = try await scanDirectory()
        _cachedHeroItems = Array(items.prefix(10))
        return _cachedHeroItems
    }

    public func fetchContinueWatching() async throws -> [MediaItem] {
        try await scanDirectory()
    }

    public func fetchRecentlyAdded() async throws -> [MediaItem] {
        let items = try await scanDirectory()
        _cachedRecentlyAdded = items.sorted { a, b in
            a.year > b.year
        }
        return _cachedRecentlyAdded
    }

    public func fetchCollections() async throws -> [MediaItem] {
        let baseURL = connection.baseURL
        guard let basePath = smbLocalPath(from: baseURL) else {
            _cachedCollections = []
            return []
        }
        var directories: [MediaItem] = []
        let fm = FileManager.default
        if let contents = try? fm.contentsOfDirectory(atPath: basePath) {
            for name in contents {
                var isDir: ObjCBool = false
                let fullPath = (basePath as NSString).appendingPathComponent(name)
                if fm.fileExists(atPath: fullPath, isDirectory: &isDir), isDir.boolValue {
                    directories.append(MediaItem(
                        title: name, subtitle: "Directory", overview: "",
                        durationText: "", progress: 0, year: "", genres: ["Folder"],
                        accent: .emerald, artworkSymbol: "folder.fill", resolution: "",
                        audio: "", heroBadge: "Folder", contentType: "Directory",
                        rating: "", heroChromeStyle: .dark, heroArtworkStyle: .noir
                    ))
                }
            }
        }
        _cachedCollections = directories
        return _cachedCollections
    }

    public func search(query: String) async throws -> [MediaItem] {
        let all = try await scanDirectory()
        return all.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    // MARK: - Playback

    public func fetchStreamURL(for item: MediaItem) async throws -> URL {
        let baseURL = connection.baseURL
        guard let basePath = smbLocalPath(from: baseURL) else {
            throw ServerAdapterError.missingStreamURL
        }
        let filePath = (basePath as NSString).appendingPathComponent(item.id.uuidString)
        return URL(fileURLWithPath: filePath)
    }

    public func fetchSubtitles(for item: MediaItem) async throws -> [SubtitleTrack] {
        let baseURL = connection.baseURL
        guard let basePath = smbLocalPath(from: baseURL) else { return [] }
        let fm = FileManager.default
        let dirPath = (basePath as NSString).deletingLastPathComponent
        guard let contents = try? fm.contentsOfDirectory(atPath: dirPath) else { return [] }
        return contents
            .filter { name in subtitleExtensions.contains((name as NSString).pathExtension.lowercased()) }
            .enumerated()
            .map { index, name in
                let lang = String(name.prefix(while: { $0 != "." }))
                return SubtitleTrack(
                    label: name,
                    language: lang.count <= 3 ? lang : "und",
                    codec: (name as NSString).pathExtension.lowercased(),
                    isExternal: true,
                    deliveryURL: URL(fileURLWithPath: (dirPath as NSString).appendingPathComponent(name))
                )
            }
    }

    public func fetchAudioTracks(for item: MediaItem) async throws -> [AudioTrack] {
        [AudioTrack(label: "Default", language: "und", codec: "aac", channels: 2, isDefault: true)]
    }

    public func reportPlaybackProgress(itemId: UUID, position: TimeInterval) async throws {}

    // MARK: - Private

    private func scanDirectory() async throws -> [MediaItem] {
        let baseURL = connection.baseURL
        guard let basePath = smbLocalPath(from: baseURL) else { return [] }
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(atPath: basePath) else { return [] }
        return contents.compactMap { name in
            let ext = (name as NSString).pathExtension.lowercased()
            guard videoExtensions.contains(ext) else { return nil }
            let fullPath = (basePath as NSString).appendingPathComponent(name)
            let attrs = try? fm.attributesOfItem(atPath: fullPath)
            let fileSize = (attrs?[.size] as? Int64) ?? 0
            let modDate = attrs?[.modificationDate] as? Date
            let id = UUID()
            return MediaItem(
                id: id, title: (name as NSString).deletingPathExtension,
                subtitle: formatSize(fileSize), overview: fullPath,
                durationText: "", progress: 0, year: modDate.map { formatDate($0) } ?? "",
                genres: [ext.uppercased()], accent: accentColor(for: id.uuidString),
                artworkSymbol: "play.rectangle.fill", resolution: "",
                audio: "", heroBadge: ext.uppercased(), contentType: "Movie",
                rating: "", heroChromeStyle: .dark, heroArtworkStyle: .noir
            )
        }
    }

    private func smbLocalPath(from url: URL) -> String? {
        guard url.scheme == "smb" || url.scheme == "file" else { return nil }
        if url.scheme == "file" { return url.path }
        return "/Volumes/\(url.host ?? "")\(url.path)"
    }

    private func formatSize(_ bytes: Int64) -> String {
        let gb = Double(bytes) / 1_000_000_000
        if gb > 1 { return String(format: "%.1f GB", gb) }
        return String(format: "%.0f MB", Double(bytes) / 1_000_000)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }

    private func accentColor(for key: String) -> ColorToken {
        let colors: [ColorToken] = [.ember, .cobalt, .emerald, .rose, .amber]
        return colors[abs(key.hashValue) % colors.count]
    }
}
