import LuminplayCore
import SwiftUI

struct TVContentView: View {
    @EnvironmentObject private var store: LuminplayStore

    var body: some View {
        TabView(selection: $store.selectedSection) {
            Tab(AppSection.home.title, systemImage: AppSection.home.systemImage, value: .home) {
                TVHomeView(store: store)
            }
            Tab(AppSection.library.title, systemImage: AppSection.library.systemImage, value: .library) {
                TVLibraryView(store: store)
            }
            Tab(AppSection.settings.title, systemImage: AppSection.settings.systemImage, value: .settings) {
                TVSettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

// MARK: - Home

struct TVHomeView: View {
    @ObservedObject var store: LuminplayStore

    var body: some View {
        ZStack {
            LuminplayBackdrop(accent: store.selectedFeaturedItem.accent)

            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 48) {
                    TVHeroCarousel(store: store)

                    TVMediaRail(
                        title: "Continue Watching",
                        items: store.continueWatching,
                        favorites: store.favorites,
                        onPlay: { store.play($0) },
                        onFavorite: { store.toggleFavorite($0) }
                    )

                    TVMediaRail(
                        title: "Recently Added",
                        items: store.recentlyAdded,
                        favorites: store.favorites,
                        onPlay: { store.play($0) },
                        onFavorite: { store.toggleFavorite($0) }
                    )

                    TVMediaRail(
                        title: "Collections",
                        items: store.collections,
                        favorites: store.favorites,
                        onPlay: { store.play($0) },
                        onFavorite: { store.toggleFavorite($0) }
                    )
                }
                .padding(.horizontal, 90)
                .padding(.vertical, 60)
            }
        }
    }
}

// MARK: - Hero Carousel

struct TVHeroCarousel: View {
    @ObservedObject var store: LuminplayStore
    @FocusState private var focusedIndex: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Featured")
                .font(.system(size: 38, weight: .bold))
                .foregroundStyle(.white)

            ScrollView(.horizontal) {
                HStack(spacing: 32) {
                    ForEach(Array(store.heroItems.enumerated()), id: \.element.id) { index, item in
                        TVHeroCard(item: item, isFocused: focusedIndex == index)
                            .focusable(true) { newState in
                                if newState {
                                    focusedIndex = index
                                    store.selectedFeaturedItem = item
                                }
                            }
                            .onTapGesture {
                                store.play(item)
                            }
                    }
                }
                .padding(.horizontal, 90)
            }
            .scrollClipDisabled()
        }
    }
}

struct TVHeroCard: View {
    let item: MediaItem
    let isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(item.accent.gradient)
                .frame(width: 520, height: 292)
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title)
                            .font(.system(size: 32, weight: .bold))
                        Text(item.subtitle)
                            .font(.title3)
                    }
                    .foregroundStyle(.white)
                    .padding(24)
                }
                .shadow(color: item.accent.tint.opacity(isFocused ? 0.6 : 0), radius: 24)

            if isFocused {
                VStack(alignment: .leading, spacing: 12) {
                    Text(item.overview)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(3)

                    HStack(spacing: 12) {
                        ForEach(item.genres.prefix(3), id: \.self) { genre in
                            Text(genre)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.white.opacity(0.9))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(.white.opacity(0.12), in: Capsule())
                        }
                        Text(item.resolution)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(width: 520)
        .scaleEffect(isFocused ? 1.08 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
    }
}

// MARK: - Media Rail

struct TVMediaRail: View {
    let title: String
    let items: [MediaItem]
    let favorites: Set<UUID>
    let onPlay: (MediaItem) -> Void
    let onFavorite: (MediaItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white)

            ScrollView(.horizontal) {
                HStack(spacing: 24) {
                    ForEach(items) { item in
                        TVFocusableCard(
                            item: item,
                            isFavorite: favorites.contains(item.id),
                            onPlay: { onPlay(item) },
                            onFavorite: { onFavorite(item) }
                        )
                    }
                }
            }
        }
    }
}
