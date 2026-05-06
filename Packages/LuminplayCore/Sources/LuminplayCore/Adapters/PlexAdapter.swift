import Foundation

public final class PlexAdapter: ServerAdapter, @unchecked Sendable {
    public let connection: ServerConnection
    public private(set) var isAuthenticated = false

    private let baseURL: URL
    private var token: String?
    private let session: URLSession
    private var sections: [PlexSection] = []

    public init(connection: ServerConnection) {
        self.connection = connection
        self.baseURL = connection.baseURL
        self.token = connection.apiKey
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    public func connect() async throws {
        var req = makeRequest("/identity")
        let (_, response) = try await session.data(for: req)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ServerAdapterError.notAuthenticated
        }
        isAuthenticated = true
    }

    public func disconnect() {
        isAuthenticated = false
        sections = []
    }

    public func authenticate(username: String, password: String) async throws {
        let bodyString = "user[login]=\(username)&user[password]=\(password)"
        guard let body = bodyString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.data(using: .utf8) else {
            throw ServerAdapterError.notAuthenticated
        }

        var req = URLRequest(url: URL(string: "https://plex.tv/api/v2/users/sign_in")!)
        req.httpMethod = "POST"
        req.setValue("application/xml", forHTTPHeaderField: "Accept")
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.httpBody = body

        let (data, _) = try await session.data(for: req)
        guard let xml = String(data: data, encoding: .utf8),
              let extractedToken = extractAttribute(from: xml, tag: "user", attribute: "authToken") else {
            throw ServerAdapterError.notAuthenticated
        }
        self.token = extractedToken
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

    private var allSections: [PlexSection] {
        get async throws {
            if sections.isEmpty {
                sections = try await fetchSections()
            }
            return sections
        }
    }

    public func fetchHeroItems() async throws -> [MediaItem] {
        let sections = try await allSections
        guard let firstSection = sections.first else { return [] }
        _cachedHeroItems = try await fetchSectionItems(sectionKey: firstSection.key, limit: 10)
        return _cachedHeroItems
    }

    public func fetchContinueWatching() async throws -> [MediaItem] {
        let sections = try await allSections
        var allItems: [MediaItem] = []
        for section in sections.prefix(3) {
            let items = try await fetchSectionItems(sectionKey: section.key, limit: 20)
            allItems.append(contentsOf: items.filter { $0.progress > 0 })
        }
        _cachedContinueWatching = Array(allItems.prefix(20))
        return _cachedContinueWatching
    }

    public func fetchRecentlyAdded() async throws -> [MediaItem] {
        let sections = try await allSections
        var allItems: [MediaItem] = []
        for section in sections.prefix(3) {
            allItems.append(contentsOf: try await fetchSectionItems(sectionKey: section.key, limit: 20))
        }
        _cachedRecentlyAdded = allItems
        return _cachedRecentlyAdded
    }

    public func fetchCollections() async throws -> [MediaItem] {
        let data = try await fetchXML("/library/sections")
        guard let xml = String(data: data, encoding: .utf8) else { return [] }
        let collectionSections = extractTags(xml, tag: "Directory")
            .filter { $0.contains("type=\"collection\"") || $0.contains("type=\"playlist\"") }
        var result: [MediaItem] = []
        for sectionTag in collectionSections {
            if let key = extractAttribute(from: sectionTag, tag: "Directory", attribute: "key") {
                result.append(contentsOf: try await fetchSectionItems(sectionKey: key, limit: 20))
            }
        }
        _cachedCollections = result
        return _cachedCollections
    }

    public func search(query: String) async throws -> [MediaItem] {
        let sections = try await allSections
        var allItems: [MediaItem] = []
        for section in sections.prefix(3) {
            let data = try await fetchXML("/library/sections/\(section.key)/all",
                queryItems: [URLQueryItem(name: "title", value: query)])
            allItems.append(contentsOf: parseItems(from: data))
        }
        return allItems
    }

    // MARK: - Playback

    public func fetchStreamURL(for item: MediaItem) async throws -> URL {
        let data = try await fetchXML("/library/metadata/\(item.id.uuidString)")
        guard let xml = String(data: data, encoding: .utf8),
              let partKey = extractAttribute(from: xml, tag: "Part", attribute: "key") else {
            throw ServerAdapterError.missingStreamURL
        }
        return baseURL.appendingPathComponent(partKey)
    }

    public func fetchSubtitles(for item: MediaItem) async throws -> [SubtitleTrack] {
        let data = try await fetchXML("/library/metadata/\(item.id.uuidString)")
        guard let xml = String(data: data, encoding: .utf8) else { return [] }
        return extractTags(xml, tag: "Stream")
            .filter { $0.contains("streamType=\"3\"") }
            .enumerated()
            .map { index, tag in
                SubtitleTrack(
                    label: extractAttribute(from: tag, tag: "Stream", attribute: "title") ?? "Subtitle \(index + 1)",
                    language: extractAttribute(from: tag, tag: "Stream", attribute: "languageCode") ?? "und",
                    codec: extractAttribute(from: tag, tag: "Stream", attribute: "codec") ?? "srt",
                    isForced: extractAttribute(from: tag, tag: "Stream", attribute: "forced") == "1",
                    isExternal: false,
                    deliveryURL: nil
                )
            }
    }

    public func fetchAudioTracks(for item: MediaItem) async throws -> [AudioTrack] {
        let data = try await fetchXML("/library/metadata/\(item.id.uuidString)")
        guard let xml = String(data: data, encoding: .utf8) else { return [] }
        return extractTags(xml, tag: "Stream")
            .filter { $0.contains("streamType=\"2\"") }
            .map { tag in
                AudioTrack(
                    label: extractAttribute(from: tag, tag: "Stream", attribute: "title") ?? "Unknown",
                    language: extractAttribute(from: tag, tag: "Stream", attribute: "languageCode") ?? "und",
                    codec: extractAttribute(from: tag, tag: "Stream", attribute: "codec") ?? "aac",
                    channels: Int(extractAttribute(from: tag, tag: "Stream", attribute: "channels") ?? "2") ?? 2,
                    isDefault: extractAttribute(from: tag, tag: "Stream", attribute: "default") == "1"
                )
            }
    }

    public func reportPlaybackProgress(itemId: UUID, position: TimeInterval) async throws {
        _ = try await fetchXML("/:/timeline", queryItems: [
            URLQueryItem(name: "ratingKey", value: itemId.uuidString),
            URLQueryItem(name: "time", value: String(Int64(position * 1000))),
            URLQueryItem(name: "state", value: "playing")
        ])
    }

    // MARK: - Private helpers

    private func fetchXML(_ path: String, queryItems: [URLQueryItem] = []) async throws -> Data {
        var req = makeRequest(path, queryItems: queryItems)
        let (data, response) = try await session.data(for: req)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw ServerAdapterError.notAuthenticated
        }
        return data
    }

    private func makeRequest(_ path: String, queryItems: [URLQueryItem] = []) -> URLRequest {
        var url = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !queryItems.isEmpty {
            url.queryItems = queryItems
        }
        var req = URLRequest(url: url.url!)
        req.setValue("application/xml", forHTTPHeaderField: "Accept")
        if let token = token {
            req.setValue(token, forHTTPHeaderField: "X-Plex-Token")
        }
        return req
    }

    private func fetchSections() async throws -> [PlexSection] {
        let data = try await fetchXML("/library/sections")
        guard let xml = String(data: data, encoding: .utf8) else { return [] }
        return extractTags(xml, tag: "Directory")
            .filter { tag in
                let type = extractAttribute(from: tag, tag: "Directory", attribute: "type") ?? ""
                return type == "movie" || type == "show"
            }
            .compactMap { tag in
                guard let key = extractAttribute(from: tag, tag: "Directory", attribute: "key"),
                      let title = extractAttribute(from: tag, tag: "Directory", attribute: "title") else { return nil }
                return PlexSection(key: key, title: title)
            }
    }

    private func fetchSectionItems(sectionKey: String, limit: Int) async throws -> [MediaItem] {
        let data = try await fetchXML("/library/sections/\(sectionKey)/all", queryItems: [
            URLQueryItem(name: "sort", value: "addedAt:desc"),
            URLQueryItem(name: "X-Plex-Container-Size", value: String(limit))
        ])
        return parseItems(from: data)
    }

    private func parseItems(from data: Data) -> [MediaItem] {
        guard let xml = String(data: data, encoding: .utf8) else { return [] }
        return extractTags(xml, tag: "Video").compactMap { tag in
            guard let ratingKey = extractAttribute(from: tag, tag: "Video", attribute: "ratingKey"),
                  let title = extractAttribute(from: tag, tag: "Video", attribute: "title"),
                  let id = UUID(uuidString: ratingKey) else { return nil }

            let type = extractAttribute(from: tag, tag: "Video", attribute: "type") ?? "movie"
            let durationMs = Double(extractAttribute(from: tag, tag: "Video", attribute: "duration") ?? "0") ?? 0
            let viewOffset = Double(extractAttribute(from: tag, tag: "Video", attribute: "viewOffset") ?? "0") ?? 0
            let progress = durationMs > 0 ? viewOffset / durationMs : 0
            let year = extractAttribute(from: tag, tag: "Video", attribute: "year") ?? ""
            let rating = extractAttribute(from: tag, tag: "Video", attribute: "contentRating") ?? "NR"
            let summary = extractAttribute(from: tag, tag: "Video", attribute: "summary") ?? ""
            let genreStr = extractAttribute(from: tag, tag: "Video", attribute: "genre") ?? ""
            let genres = genreStr.components(separatedBy: ", ").filter { !$0.isEmpty }
            let width = Int(extractAttribute(from: tag, tag: "Video", attribute: "width") ?? "0") ?? 0

            return MediaItem(
                id: id,
                title: title,
                subtitle: type == "show" ? "Series" : "Movie",
                overview: summary,
                durationText: formatDuration(durationMs),
                progress: progress,
                year: year,
                genres: genres,
                accent: accentColor(for: ratingKey),
                artworkSymbol: type == "show" ? "tv.fill" : "film.fill",
                resolution: width >= 3840 ? "4K" : width >= 1920 ? "1080p" : "",
                audio: "Surround",
                heroBadge: type == "show" ? "Series" : "Movie",
                contentType: type == "show" ? "TV Series" : "Movie",
                rating: rating,
                heroChromeStyle: .light,
                heroArtworkStyle: .solar
            )
        }
    }

    private func extractAttribute(from xml: String, tag _: String, attribute: String) -> String? {
        let pattern = "\(attribute)=\"([^\"]*)\""
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: xml, range: NSRange(xml.startIndex..., in: xml)) else { return nil }
        guard let range = Range(match.range(at: 1), in: xml) else { return nil }
        return String(xml[range])
    }

    private func extractTags(_ xml: String, tag: String) -> [String] {
        let pattern = "<\(tag)\\s[^>]*/?>"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        return regex.matches(in: xml, range: NSRange(xml.startIndex..., in: xml)).compactMap { match in
            guard let range = Range(match.range, in: xml) else { return nil }
            return String(xml[range])
        }
    }

    private func formatDuration(_ ms: Double) -> String {
        let totalSeconds = Int(ms / 1000)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }

    private func accentColor(for key: String) -> ColorToken {
        let colors: [ColorToken] = [.ember, .cobalt, .emerald, .rose, .amber]
        return colors[abs(key.hashValue) % colors.count]
    }
}

private struct PlexSection {
    let key: String
    let title: String
}
