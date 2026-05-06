import LuminplayCore
import SwiftUI

struct MainStageView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let store: LuminplayStore

    var body: some View {
        if usesCompactIOSHome {
            CompactIOSHomeView(store: store)
        } else {
            ZStack {
                LuminplayBackdrop(accent: store.selectedFeaturedItem.accent)
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        HeroShowcaseView(store: store)

                        MediaRailSection(
                            title: "Continue Watching",
                            subtitle: "Instant resume with playback progress and subtitle memory.",
                            items: store.continueWatching,
                            favorites: store.favorites,
                            onSelect: { store.play($0) },
                            onToggleFavorite: { store.toggleFavorite($0) }
                        )
                        .padding(.leading, horizontalPadding)

                        MediaRailSection(
                            title: "Recently Added",
                            subtitle: "Poster-first browsing optimized for private media servers.",
                            items: store.recentlyAdded,
                            favorites: store.favorites,
                            onSelect: { store.play($0) },
                            onToggleFavorite: { store.toggleFavorite($0) }
                        )
                        .padding(.leading, horizontalPadding)

                        MediaRailSection(
                            title: "Collections",
                            subtitle: "Curated shelves, series, playlists, and genre hubs.",
                            items: store.collections,
                            favorites: store.favorites,
                            onSelect: { store.play($0) },
                            onToggleFavorite: { store.toggleFavorite($0) }
                        )
                        .padding(.leading, horizontalPadding)

                        DevicesReadinessView(capabilities: store.deviceCapabilities)
                            .padding(.horizontal, horizontalPadding)
                    }
                    .padding(.vertical, 24)
                }
            }
        }
    }

    private var heroTopPadding: CGFloat {
        #if os(macOS)
        28
        #else
        0
        #endif
    }

    private var horizontalPadding: CGFloat {
        #if os(visionOS)
        44
        #elseif os(macOS)
        32
        #else
        20
        #endif
    }

    private var usesCompactIOSHome: Bool {
        #if os(iOS)
        horizontalSizeClass == .compact
        #else
        false
        #endif
    }
}
