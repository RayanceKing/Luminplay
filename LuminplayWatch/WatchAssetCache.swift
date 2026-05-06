import Foundation
import SwiftUI

final class WatchAssetCache {
    static let shared = WatchAssetCache()
    private let maxCacheSize = 20 * 1024 * 1024 // 20MB
    private var cache: [UUID: Image] = [:]
    private var cacheSize: Int = 0

    private init() {}

    func image(for itemId: UUID) -> Image? {
        cache[itemId]
    }

    func cacheImage(_ image: Image, for itemId: UUID) {
        cache[itemId] = image
        // Simple LRU eviction: remove oldest if over limit
        if cache.count > 30 {
            if let firstKey = cache.keys.first {
                cache.removeValue(forKey: firstKey)
            }
        }
    }

    func clear() {
        cache.removeAll()
    }
}
