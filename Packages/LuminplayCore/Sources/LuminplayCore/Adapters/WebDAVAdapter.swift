import Foundation

public final class WebDAVAdapter: ServerAdapter, @unchecked Sendable {
    public let connection: ServerConnection
    public private(set) var isAuthenticated = false

    private let baseURL: URL
    private let session: URLSession
    private var credentials: (username: String, password: String)?

    private let videoExtensions: Set<String> = [
        "mkv", "mp4", "m4v", "mov", "avi", "wmv", "flv", "webm", "ts", "m2ts", "iso"
    ]

    public init(connection: ServerConnection) {
        self.connection = connection
        self.baseURL = connection.baseURL
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    public func connect() async throws {
        let req = makePROPFIND(path: "/", depth: "0")
        let (_, response) = try await session.data(for: req)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 207 || httpResponse.statusCode == 200 else {
            throw ServerAdapterError.notAuthenticated
        }
        isAuthenticated = true
    }

    public func disconnect() {
        isAuthenticated = false
    }

    public func authenticate(username: String, password: String) async throws {
        credentials = (username, password)
        try await connect()
    }

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
        let items = try await scanDirectory(path: "/")
        _cachedHeroItems = Array(items.prefix(10))
        return _cachedHeroItems
    }

    public func fetchContinueWatching() async throws -> [MediaItem] {
        try await scanDirectory(path: "/")
    }

    public func fetchRecentlyAdded() async throws -> [MediaItem] {
        let items = try await scanDirectory(path: "/")
        _cachedRecentlyAdded = items.sorted { a, b in
            a.year > b.year
        }
        return _cachedRecentlyAdded
    }

    public func fetchCollections() async throws -> [MediaItem] {
        let entries = try await listDirectories(path: "/")
        _cachedCollections = entries.map { name in
            MediaItem(
                title: name, subtitle: "Directory", overview: "",
                durationText: "", progress: 0, year: "", genres: ["Folder"],
                accent: .emerald, artworkSymbol: "folder.fill", resolution: "",
                audio: "", heroBadge: "Folder", contentType: "Directory",
                rating: "", heroChromeStyle: .dark, heroArtworkStyle: .noir
            )
        }
        return _cachedCollections
    }

    public func search(query: String) async throws -> [MediaItem] {
        let all = try await scanDirectory(path: "/")
        return all.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    // MARK: - Playback

    public func fetchStreamURL(for item: MediaItem) async throws -> URL {
        baseURL.appendingPathComponent(item.overview)
    }

    public func fetchSubtitles(for item: MediaItem) async throws -> [SubtitleTrack] {
        let dirPath = (item.overview as NSString).deletingLastPathComponent
        let entries = try await listDirectory(path: dirPath)
        return entries
            .filter { $0.hasSuffix(".srt") || $0.hasSuffix(".vtt") || $0.hasSuffix(".ass") }
            .enumerated()
            .map { index, name in
                SubtitleTrack(
                    label: name, language: "und",
                    codec: (name as NSString).pathExtension.lowercased(),
                    isExternal: true,
                    deliveryURL: baseURL.appendingPathComponent("\(dirPath)/\(name)")
                )
            }
    }

    public func fetchAudioTracks(for item: MediaItem) async throws -> [AudioTrack] {
        [AudioTrack(label: "Default", language: "und", codec: "aac", channels: 2, isDefault: true)]
    }

    public func reportPlaybackProgress(itemId: UUID, position: TimeInterval) async throws {}

    // MARK: - Private

    private func scanDirectory(path: String) async throws -> [MediaItem] {
        let entries = try await listDirectory(path: path)
        return entries.compactMap { name -> MediaItem? in
            let ext = (name as NSString).pathExtension.lowercased()
            guard videoExtensions.contains(ext) else { return nil }
            let id = UUID()
            let fullPath = path.hasSuffix("/") ? "\(path)\(name)" : "\(path)/\(name)"
            return MediaItem(
                id: id, title: (name as NSString).deletingPathExtension,
                subtitle: ext.uppercased(), overview: fullPath,
                durationText: "", progress: 0, year: "",
                genres: [ext.uppercased()],
                accent: accentColor(for: id.uuidString),
                artworkSymbol: "play.rectangle.fill", resolution: "",
                audio: "", heroBadge: ext.uppercased(), contentType: "Movie",
                rating: "", heroChromeStyle: .dark, heroArtworkStyle: .noir
            )
        }
    }

    private func listDirectory(path: String) async throws -> [String] {
        let data = try await makePROPFINDRequest(path: path, depth: "1")
        guard let xml = String(data: data, encoding: .utf8) else { return [] }
        return extractResponseNames(from: xml).filter { $0 != path && !$0.isEmpty }
    }

    private func listDirectories(path: String) async throws -> [String] {
        let data = try await makePROPFINDRequest(path: path, depth: "1")
        guard let xml = String(data: data, encoding: .utf8) else { return [] }
        let allNames = extractResponseNames(from: xml)
        return allNames.filter { name in
            name != path && !name.contains(".")
        }
    }

    private func makePROPFINDRequest(path: String, depth: String) async throws -> Data {
        let req = makePROPFIND(path: path, depth: depth)
        let (data, response) = try await session.data(for: req)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 207 || httpResponse.statusCode == 200 else {
            throw ServerAdapterError.notAuthenticated
        }
        return data
    }

    private func makePROPFIND(path: String, depth: String) -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = "PROPFIND"
        req.setValue("application/xml", forHTTPHeaderField: "Accept")
        req.setValue(depth, forHTTPHeaderField: "Depth")
        return req
    }

    private func extractResponseNames(from xml: String) -> [String] {
        let pattern = "<d:href>([^<]+)</d:href>"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        return regex.matches(in: xml, range: NSRange(xml.startIndex..., in: xml)).compactMap { match in
            guard let range = Range(match.range(at: 1), in: xml) else { return nil }
            let href = String(xml[range])
            return href.removingPercentEncoding ?? href
        }
    }

    private func accentColor(for key: String) -> ColorToken {
        let colors: [ColorToken] = [.ember, .cobalt, .emerald, .rose, .amber]
        return colors[abs(key.hashValue) % colors.count]
    }
}
