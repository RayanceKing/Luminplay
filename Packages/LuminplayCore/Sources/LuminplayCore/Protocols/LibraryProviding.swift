import Foundation

public protocol LibraryProviding: Sendable {
    var heroItems: [MediaItem] { get }
    var featured: MediaItem { get }
    var continueWatching: [MediaItem] { get }
    var recentlyAdded: [MediaItem] { get }
    var collections: [MediaItem] { get }

    func fetchHeroItems() async throws -> [MediaItem]
    func fetchContinueWatching() async throws -> [MediaItem]
    func fetchRecentlyAdded() async throws -> [MediaItem]
    func fetchCollections() async throws -> [MediaItem]
    func search(query: String) async throws -> [MediaItem]
}

public extension LibraryProviding {
    func fetchHeroItems() async throws -> [MediaItem] { heroItems }
    func fetchContinueWatching() async throws -> [MediaItem] { continueWatching }
    func fetchRecentlyAdded() async throws -> [MediaItem] { recentlyAdded }
    func fetchCollections() async throws -> [MediaItem] { collections }
    func search(query: String) async throws -> [MediaItem] {
        let all = heroItems + continueWatching + recentlyAdded + collections
        guard !query.isEmpty else { return all }
        return all.filter { item in
            item.title.localizedCaseInsensitiveContains(query)
            || item.genres.contains { $0.localizedCaseInsensitiveContains(query) }
            || item.subtitle.localizedCaseInsensitiveContains(query)
        }
    }
}
