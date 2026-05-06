import Foundation

public final class EmbyAdapter: ServerAdapter, @unchecked Sendable {
    public let connection: ServerConnection
    public private(set) var isAuthenticated = false

    private let client: HTTPClient
    private var userID: String = ""

    public init(connection: ServerConnection) {
        self.connection = connection
        self.client = HTTPClient(baseURL: connection.baseURL)

        if let token = connection.apiKey {
            client.setAuthHeader(key: "X-Emby-Token", value: token)
        }
    }

    public func connect() async throws {
        let _: EmbySystemInfo = try await client.get("/emby/System/Info")
        isAuthenticated = true
    }

    public func disconnect() {
        isAuthenticated = false
        userID = ""
    }

    public func authenticate(username: String, password: String) async throws {
        let body = try JSONEncoder().encode(EmbyAuthRequest(username: username, pw: password))
        let response: EmbyAuthResponse = try await client.post("/emby/Users/AuthenticateByName", body: body)
        client.setAuthHeader(key: "X-Emby-Token", value: response.accessToken)
        userID = response.user.id
        isAuthenticated = true
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
            title: "Loading", subtitle: "", overview: "",
            durationText: "", progress: 0, year: "", genres: [],
            accent: .cobalt, artworkSymbol: "tv.fill", resolution: "",
            audio: "", heroBadge: "", contentType: "", rating: "",
            heroChromeStyle: .dark, heroArtworkStyle: .aurora
        )
    }

    public func fetchHeroItems() async throws -> [MediaItem] {
        let response: EmbyItemsResponse = try await client.get("/emby/Users/\(userID)/Items", queryItems: [
            URLQueryItem(name: "SortBy", value: "DateCreated"),
            URLQueryItem(name: "SortOrder", value: "Descending"),
            URLQueryItem(name: "Limit", value: "10"),
            URLQueryItem(name: "Recursive", value: "true"),
            URLQueryItem(name: "IncludeItemTypes", value: "Movie,Series")
        ])
        _cachedHeroItems = response.items.map(mapEmbyItem)
        return _cachedHeroItems
    }

    public func fetchContinueWatching() async throws -> [MediaItem] {
        let response: EmbyItemsResponse = try await client.get("/emby/Users/\(userID)/Items", queryItems: [
            URLQueryItem(name: "SortBy", value: "DatePlayed"),
            URLQueryItem(name: "SortOrder", value: "Descending"),
            URLQueryItem(name: "Limit", value: "20"),
            URLQueryItem(name: "Recursive", value: "true"),
            URLQueryItem(name: "Filters", value: "IsResumable"),
            URLQueryItem(name: "IncludeItemTypes", value: "Movie,Episode")
        ])
        _cachedContinueWatching = response.items.map(mapEmbyItem)
        return _cachedContinueWatching
    }

    public func fetchRecentlyAdded() async throws -> [MediaItem] {
        let response: EmbyItemsResponse = try await client.get("/emby/Users/\(userID)/Items", queryItems: [
            URLQueryItem(name: "SortBy", value: "DateCreated"),
            URLQueryItem(name: "SortOrder", value: "Descending"),
            URLQueryItem(name: "Limit", value: "20"),
            URLQueryItem(name: "Recursive", value: "true"),
            URLQueryItem(name: "IncludeItemTypes", value: "Movie,Series")
        ])
        _cachedRecentlyAdded = response.items.map(mapEmbyItem)
        return _cachedRecentlyAdded
    }

    public func fetchCollections() async throws -> [MediaItem] {
        let response: EmbyItemsResponse = try await client.get("/emby/Users/\(userID)/Items", queryItems: [
            URLQueryItem(name: "SortBy", value: "SortName"),
            URLQueryItem(name: "SortOrder", value: "Ascending"),
            URLQueryItem(name: "IncludeItemTypes", value: "BoxSet"),
            URLQueryItem(name: "Recursive", value: "true")
        ])
        _cachedCollections = response.items.map(mapEmbyItem)
        return _cachedCollections
    }

    public func search(query: String) async throws -> [MediaItem] {
        let response: EmbyItemsResponse = try await client.get("/emby/Users/\(userID)/Items", queryItems: [
            URLQueryItem(name: "SearchTerm", value: query),
            URLQueryItem(name: "Recursive", value: "true"),
            URLQueryItem(name: "IncludeItemTypes", value: "Movie,Series,Episode")
        ])
        return response.items.map(mapEmbyItem)
    }

    public func fetchStreamURL(for item: MediaItem) async throws -> URL {
        let response: EmbyPlaybackInfoResponse = try await client.post(
            "/emby/Items/\(item.id.uuidString)/PlaybackInfo"
        )
        guard let source = response.mediaSources.first,
              let streamURL = URL(string: source.path ?? "/Videos/\(item.id.uuidString)/stream") else {
            throw ServerAdapterError.missingStreamURL
        }
        return streamURL.host != nil ? streamURL : connection.baseURL.appendingPathComponent(streamURL.path)
    }

    public func fetchSubtitles(for item: MediaItem) async throws -> [SubtitleTrack] {
        let response: EmbyPlaybackInfoResponse = try await client.post(
            "/emby/Items/\(item.id.uuidString)/PlaybackInfo"
        )
        guard let source = response.mediaSources.first else { return [] }
        return source.mediaStreams
            .filter { $0.type == "Subtitle" }
            .enumerated()
            .map { index, stream in
                SubtitleTrack(
                    label: stream.displayTitle ?? stream.language ?? "Unknown",
                    language: stream.language ?? "und",
                    codec: stream.codec ?? "srt",
                    isForced: stream.isForced == true,
                    isExternal: stream.isExternal == true,
                    deliveryURL: stream.isExternal == true
                        ? connection.baseURL.appendingPathComponent("/Videos/\(item.id.uuidString)/Subtitles/\(index)")
                        : nil
                )
            }
    }

    public func fetchAudioTracks(for item: MediaItem) async throws -> [AudioTrack] {
        let response: EmbyPlaybackInfoResponse = try await client.post(
            "/emby/Items/\(item.id.uuidString)/PlaybackInfo"
        )
        guard let source = response.mediaSources.first else { return [] }
        return source.mediaStreams
            .filter { $0.type == "Audio" }
            .map { stream in
                AudioTrack(
                    label: stream.displayTitle ?? stream.language ?? "Unknown",
                    language: stream.language ?? "und",
                    codec: stream.codec ?? "aac",
                    channels: stream.channels ?? 2,
                    isDefault: stream.isDefault == true
                )
            }
    }

    public func reportPlaybackProgress(itemId: UUID, position: TimeInterval) async throws {
        struct ProgressBody: Encodable {
            let itemId: String
            let positionTicks: Int64
        }
        let body = try JSONEncoder().encode(ProgressBody(
            itemId: itemId.uuidString,
            positionTicks: Int64(position * 10_000_000)
        ))
        try await client.postVoid("/emby/Sessions/Playing/Progress", body: body)
    }

    private func mapEmbyItem(_ dto: EmbyBaseItemDto) -> MediaItem {
        MediaItem(
            id: UUID(uuidString: dto.id) ?? UUID(),
            title: dto.name ?? "Unknown",
            subtitle: subtitle(for: dto),
            overview: dto.overview ?? "",
            durationText: formatDuration(dto.runTimeTicks),
            progress: dto.userData?.playedPercentage.map { $0 / 100 } ?? 0,
            year: year(for: dto),
            genres: dto.genres ?? [],
            accent: accentColor(for: dto),
            artworkSymbol: artworkSymbol(for: dto),
            resolution: resolutionString(for: dto),
            audio: "Surround",
            heroBadge: badge(for: dto),
            contentType: dto.type == "Series" || dto.type == "Episode" ? "TV Series" : "Movie",
            rating: dto.officialRating ?? "NR",
            heroChromeStyle: .dark,
            heroArtworkStyle: .aurora
        )
    }

    private func subtitle(for dto: EmbyBaseItemDto) -> String {
        if let episodeTitle = dto.episodeTitle, let season = dto.parentIndexNumber, let episode = dto.indexNumber {
            return "S\(season):E\(episode) \u{2022} \(episodeTitle)"
        }
        if let serieName = dto.seriesName, dto.type == "Episode" { return serieName }
        return dto.type ?? ""
    }

    private func year(for dto: EmbyBaseItemDto) -> String {
        if let year = dto.productionYear { return String(year) }
        if let premiere = dto.premiereDate { return String(premiere.prefix(4)) }
        return ""
    }

    private func formatDuration(_ ticks: Int64?) -> String {
        guard let ticks = ticks else { return "" }
        let seconds = Double(ticks) / 10_000_000
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }

    private func accentColor(for dto: EmbyBaseItemDto) -> ColorToken {
        let colors: [ColorToken] = [.ember, .cobalt, .emerald, .rose, .amber]
        return colors[abs(dto.id.hashValue) % colors.count]
    }

    private func artworkSymbol(for dto: EmbyBaseItemDto) -> String {
        switch dto.type {
        case "Movie": return "film.fill"
        case "Series": return "tv.fill"
        case "Episode": return "play.tv.fill"
        case "BoxSet": return "square.stack.3d.up.fill"
        default: return "play.rectangle.fill"
        }
    }

    private func resolutionString(for dto: EmbyBaseItemDto) -> String {
        if let width = dto.width {
            if width >= 3840 { return "4K" }
            if width >= 1920 { return "1080p" }
            if width >= 1280 { return "720p" }
            return "SD"
        }
        return ""
    }

    private func badge(for dto: EmbyBaseItemDto) -> String {
        if dto.type == "Episode", let serieName = dto.seriesName { return serieName }
        return dto.type == "Series" ? "Series" : "Movie"
    }
}

// MARK: - Emby API DTOs

private struct EmbySystemInfo: Decodable {
    let serverName: String?
    let version: String?
}

private struct EmbyAuthRequest: Encodable {
    let username: String
    let pw: String
}

private struct EmbyAuthResponse: Decodable {
    let accessToken: String
    let user: EmbyUserDto
}

private struct EmbyUserDto: Decodable {
    let id: String
    let name: String?
}

private struct EmbyItemsResponse: Decodable {
    let items: [EmbyBaseItemDto]
}

private struct EmbyBaseItemDto: Decodable {
    let id: String
    let name: String?
    let overview: String?
    let type: String?
    let runTimeTicks: Int64?
    let productionYear: Int?
    let premiereDate: String?
    let genres: [String]?
    let officialRating: String?
    let seriesName: String?
    let episodeTitle: String?
    let parentIndexNumber: Int?
    let indexNumber: Int?
    let width: Int?
    let height: Int?
    let userData: EmbyUserDataDto?
}

private struct EmbyUserDataDto: Decodable {
    let playedPercentage: Double?
    let isFavorite: Bool?
}

private struct EmbyPlaybackInfoResponse: Decodable {
    let mediaSources: [EmbyMediaSourceDto]
}

private struct EmbyMediaSourceDto: Decodable {
    let path: String?
    let mediaStreams: [EmbyMediaStreamDto]
}

private struct EmbyMediaStreamDto: Decodable {
    let type: String?
    let codec: String?
    let language: String?
    let displayTitle: String?
    let channels: Int?
    let isDefault: Bool?
    let isForced: Bool?
    let isExternal: Bool?
}
