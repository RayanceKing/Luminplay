import Combine
import Foundation
import SwiftUI

// MARK: - Demo Providers

public struct DemoLibraryProvider: LibraryProviding {
    public let heroItems: [MediaItem] = [
        .init(
            title: "For All Mankind",
            subtitle: "New Episode Every Friday",
            overview: "Alt-history space drama with expansive seasonal arcs, warm highlights, and strong silhouette staging for a premium hero surface.",
            durationText: "58m", progress: 0.0, year: "S4",
            genres: ["Drama", "Sci-Fi"], accent: .amber,
            artworkSymbol: "globe.americas.fill", resolution: "4K Dolby Vision",
            audio: "Atmos", heroBadge: "New Episode Every Friday",
            contentType: "TV Series", rating: "TV-MA",
            heroChromeStyle: .light, heroArtworkStyle: .solar
        ),
        .init(
            title: "The Studio",
            subtitle: "2026 Golden Globe(R) Winner",
            overview: "A glossy Hollywood satire with warmer interior lighting, strong faces, and premium award-season typography.",
            durationText: "46m", progress: 0.0, year: "S1",
            genres: ["Comedy"], accent: .rose,
            artworkSymbol: "sparkles.tv.fill", resolution: "4K",
            audio: "5.1", heroBadge: "2026 Golden Globe(R) Winner",
            contentType: "TV Series", rating: "TV-MA",
            heroChromeStyle: .dark, heroArtworkStyle: .gala
        ),
        .init(
            title: "Foundation",
            subtitle: "Season Premiere",
            overview: "Monumental sci-fi staging, colder nebula lighting, and a denser high-contrast foreground composition.",
            durationText: "1h 02m", progress: 0.0, year: "S3",
            genres: ["Drama", "Sci-Fi"], accent: .cobalt,
            artworkSymbol: "sparkles.rectangle.stack.fill", resolution: "4K HDR",
            audio: "Atmos", heroBadge: "Season Premiere",
            contentType: "TV Series", rating: "TV-14",
            heroChromeStyle: .light, heroArtworkStyle: .aurora
        )
    ]

    public var featured: MediaItem { heroItems[0] }

    public let continueWatching: [MediaItem] = [
        .init(title: "Dune: Part Two", subtitle: "Resume from 1:12:08", overview: "High bitrate library playback with subtitle and audio track memory.", durationText: "2h 46m", progress: 0.54, year: "2026", genres: ["Epic", "Sci-Fi"], accent: .amber, artworkSymbol: "sparkles.tv.fill", resolution: "4K", audio: "TrueHD 7.1", heroBadge: "Continue Watching", contentType: "Movie", rating: "PG-13", heroChromeStyle: .light, heroArtworkStyle: .solar),
        .init(title: "Severance", subtitle: "Episode 7", overview: "Series progress sync across pocket, desktop, and living room surfaces.", durationText: "49m", progress: 0.81, year: "S2", genres: ["Thriller", "Series"], accent: .cobalt, artworkSymbol: "rectangle.stack.person.crop.fill", resolution: "4K", audio: "5.1", heroBadge: "Continue Watching", contentType: "TV Series", rating: "TV-MA", heroChromeStyle: .light, heroArtworkStyle: .noir),
        .init(title: "The Creator", subtitle: "Resume from 0:28:41", overview: "Direct play when possible, transcode orchestration when required.", durationText: "2h 13m", progress: 0.22, year: "2026", genres: ["Action", "Sci-Fi"], accent: .rose, artworkSymbol: "film.stack.fill", resolution: "4K HDR", audio: "Atmos", heroBadge: "Continue Watching", contentType: "Movie", rating: "PG-13", heroChromeStyle: .dark, heroArtworkStyle: .gala)
    ]

    public let recentlyAdded: [MediaItem] = [
        .init(title: "Oppenheimer", subtitle: "Newly indexed", overview: "Metadata pipelines should stay server-agnostic.", durationText: "3h 00m", progress: 0.0, year: "2026", genres: ["Drama"], accent: .emerald, artworkSymbol: "popcorn.fill", resolution: "4K", audio: "DTS-HD MA", heroBadge: "Newly Added", contentType: "Movie", rating: "R", heroChromeStyle: .light, heroArtworkStyle: .aurora),
        .init(title: "Foundation", subtitle: "Season 3", overview: "Episode-aware navigation and artwork variants for franchise browsing.", durationText: "58m", progress: 0.0, year: "S3", genres: ["Series"], accent: .cobalt, artworkSymbol: "square.stack.3d.down.right.fill", resolution: "4K", audio: "Atmos", heroBadge: "Season 3", contentType: "TV Series", rating: "TV-14", heroChromeStyle: .light, heroArtworkStyle: .aurora),
        .init(title: "Spirited Away", subtitle: "Remastered", overview: "Subtitle selection, fallback fonts, and watch-list handoff.", durationText: "2h 05m", progress: 0.0, year: "2026", genres: ["Animation"], accent: .amber, artworkSymbol: "sparkles.rectangle.stack.fill", resolution: "4K", audio: "5.1", heroBadge: "Remastered", contentType: "Movie", rating: "PG", heroChromeStyle: .dark, heroArtworkStyle: .solar)
    ]

    public let collections: [MediaItem] = [
        .init(title: "Christopher Nolan", subtitle: "Director Collection", overview: "Deep browse shelves with poster-first presentation.", durationText: "8 titles", progress: 0.0, year: "Collection", genres: ["Curated"], accent: .ember, artworkSymbol: "person.crop.rectangle.stack.fill", resolution: "Mixed", audio: "Mixed", heroBadge: "Collection", contentType: "Collection", rating: "Curated", heroChromeStyle: .dark, heroArtworkStyle: .gala),
        .init(title: "Anime Night", subtitle: "Weekend Queue", overview: "Playlist, shuffle, and next-up orchestration.", durationText: "12 titles", progress: 0.0, year: "Playlist", genres: ["Family"], accent: .rose, artworkSymbol: "moon.stars.fill", resolution: "Mixed", audio: "Mixed", heroBadge: "Playlist", contentType: "Playlist", rating: "Curated", heroChromeStyle: .light, heroArtworkStyle: .noir),
        .init(title: "Documentaries", subtitle: "Reference Shelf", overview: "Category hubs built from shared metadata and filters.", durationText: "23 titles", progress: 0.0, year: "Library", genres: ["Docs"], accent: .emerald, artworkSymbol: "globe.europe.africa.fill", resolution: "Mixed", audio: "Mixed", heroBadge: "Library", contentType: "Library", rating: "Curated", heroChromeStyle: .dark, heroArtworkStyle: .aurora)
    ]

    public init() {}
}

public struct DemoSyncProvider: SyncProviding {
    public func syncPlaybackState(_ session: PlaybackSession) {}
    public func fetchPlaybackState(for itemId: UUID) async throws -> PlaybackSession? { nil }
    public func fetchUserData() async throws -> UserSyncData { UserSyncData() }
    public init() {}
}

// MARK: - Store

@MainActor
public final class LuminplayStore: ObservableObject, PlaybackEngine {
    public nonisolated(unsafe) var library: LibraryProviding
    public nonisolated(unsafe) let syncProvider: SyncProviding
    public let serverManager: ServerManager

    @Published public var selectedSection: AppSection = .home
    @Published public var selectedFeaturedItem: MediaItem
    @Published public var favorites: Set<UUID> = []
    @Published public var searchText: String = ""
    @Published public var isSidebarPresented: Bool = true
    @Published public var isServerBacked = false
    @Published public var isLoading = false

    @Published public var playbackURL: URL?
    @Published public var isShowingPlayer = false
    public let sessionManager = PlaybackSessionManager()

    public let deviceCapabilities: [DeviceCapability] = [
        .init(title: "Shared SwiftUI Shell", detail: "One navigation and presentation language across touch, pointer, and spatial surfaces.", icon: "square.stack.3d.up.fill", readiness: .ios),
        .init(title: "Desktop Theater Mode", detail: "macOS gets a denser library, windowed playback, and keyboard shortcuts.", icon: "macwindow.on.rectangle", readiness: .macOS),
        .init(title: "Living Room Target", detail: "tvOS gets focus-driven hero rails and remote-first transport controls.", icon: "tv.fill", readiness: .tvOS),
        .init(title: "Companion Wrist Surface", detail: "watchOS stays remote-first: queue, handoff, and now playing, not full playback.", icon: "applewatch", readiness: .watchOS),
        .init(title: "Spatial Cinema", detail: "visionOS gets immersive artwork, larger stage controls, and continuity handoff.", icon: "visionpro", readiness: .visionOS),
        .init(title: "Future Playback Core", detail: "Keep media graph, sync, and server adapters outside Apple-only UI code.", icon: "rectangle.3.group.bubble.left.fill", readiness: .windows),
        .init(title: "Android Preparation", detail: "Mirror the same domain contracts so Kotlin or Flutter shells can reuse services.", icon: "play.square.stack.fill", readiness: .android)
    ]

    public convenience init() {
        self.init(library: DemoLibraryProvider(), syncProvider: DemoSyncProvider())
    }

    public init(
        library: LibraryProviding,
        syncProvider: SyncProviding,
        serverManager: ServerManager = ServerManager()
    ) {
        self.library = library
        self.syncProvider = syncProvider
        self.serverManager = serverManager
        selectedFeaturedItem = library.featured
    }

    public var continueWatching: [MediaItem] { library.continueWatching }
    public var recentlyAdded: [MediaItem] { library.recentlyAdded }
    public var collections: [MediaItem] { library.collections }
    public var heroItems: [MediaItem] { library.heroItems }

    // MARK: - Server Operations

    public func connectToServer(_ connection: ServerConnection) async throws {
        serverManager.addConnection(connection)
        try await serverManager.connect(to: connection.id)
        if let adapter = serverManager.activeAdapter {
            library = adapter
            isServerBacked = true
            try await refreshLibrary()
        }
    }

    public func disconnectFromServer() {
        library = DemoLibraryProvider()
        isServerBacked = false
    }

    public func refreshLibrary() async throws {
        isLoading = true
        defer { isLoading = false }
        _ = try await library.fetchHeroItems()
        _ = try await library.fetchContinueWatching()
        _ = try await library.fetchRecentlyAdded()
        _ = try await library.fetchCollections()
        selectedFeaturedItem = library.featured
    }

    public func search(_ query: String) async throws -> [MediaItem] {
        try await library.search(query: query)
    }

    // MARK: - PlaybackEngine

    public func play(_ item: MediaItem) {
        selectedFeaturedItem = item
        Task {
            await resolveAndPlay(item)
        }
    }

    private func resolveAndPlay(_ item: MediaItem) async {
        do {
            let url: URL
            if let adapter = serverManager.activeAdapter {
                url = try await adapter.fetchStreamURL(for: item)
            } else {
                url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")!
            }
            playbackURL = url
            isShowingPlayer = true
            sessionManager.beginSession(for: item)
        } catch {
            let session = PlaybackSession(mediaItemId: item.id)
            syncProvider.syncPlaybackState(session)
        }
    }

    public func pause() { sessionManager.pause() }
    public func resume() { sessionManager.play() }
    public func seek(to position: TimeInterval) { sessionManager.seek(to: position) }
    public func setAudioTrack(_ index: Int) { sessionManager.selectAudioTrack(index) }
    public func setSubtitleTrack(_ index: Int?) { sessionManager.selectSubtitleTrack(index) }
    public func setPlaybackRate(_ rate: Float) { sessionManager.setPlaybackRate(rate) }
    public func skipForward(_ seconds: TimeInterval) { sessionManager.skipForward(seconds) }
    public func skipBackward(_ seconds: TimeInterval) { sessionManager.skipBackward(seconds) }

    public func dismissPlayer() {
        isShowingPlayer = false
        playbackURL = nil
        sessionManager.stop()
    }

    public func loadSubtitles(for item: MediaItem) async {
        guard let adapter = serverManager.activeAdapter else { return }
        if let subtitles = try? await adapter.fetchSubtitles(for: item) {
            sessionManager.availableSubtitles = subtitles
        }
        if let audioTracks = try? await adapter.fetchAudioTracks(for: item) {
            sessionManager.availableAudioTracks = audioTracks
        }
    }

    public func toggleFavorite(_ item: MediaItem) {
        if favorites.contains(item.id) {
            favorites.remove(item.id)
        } else {
            favorites.insert(item.id)
        }
    }

    public func isFavorite(_ item: MediaItem) -> Bool {
        favorites.contains(item.id)
    }
}
