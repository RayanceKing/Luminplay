import Combine
import LuminplayCore
import SwiftUI

struct CompactIOSHomeView: View {
    @ObservedObject var store: LuminplayStore

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    CompactIOSHeroCarousel(store: store)

                    VStack(alignment: .leading, spacing: 28) {
                        CompactRailSection(
                            title: "Continue Watching",
                            items: store.continueWatching,
                            favorites: store.favorites,
                            onSelect: { store.play($0) },
                            onToggleFavorite: { store.toggleFavorite($0) }
                        )
                        CompactRailSection(
                            title: "Recently Added",
                            items: store.recentlyAdded,
                            favorites: store.favorites,
                            onSelect: { store.play($0) },
                            onToggleFavorite: { store.toggleFavorite($0) }
                        )
                        CompactRailSection(
                            title: "Collections",
                            items: store.collections,
                            favorites: store.favorites,
                            onSelect: { store.play($0) },
                            onToggleFavorite: { store.toggleFavorite($0) }
                        )
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 120)
                    .background(compactSurfaceBackground)
                }
            }
            .ignoresSafeArea(edges: .top)
            .background(compactSurfaceBackground)
            .navigationTitle("Home")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.32, green: 0.74, blue: 0.99), Color(red: 0.19, green: 0.32, blue: 0.95)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                        .overlay {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(.white)
                        }
                }
                #endif
            }
        }
    }

    private var compactSurfaceBackground: Color {
        #if os(macOS)
        Color(nsColor: NSColor.windowBackgroundColor)
        #else
        Color(uiColor: UIColor.systemBackground)
        #endif
    }
}

struct CompactIOSHeroCarousel: View {
    @ObservedObject var store: LuminplayStore
    @State private var selectedHeroIndex = 0
    @State private var pagerProgress: Double = 0
    private let heroTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    private let progressTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let heroHeight = min(max(width * 1.24, 560), 690)

            ZStack(alignment: .bottom) {
                TabView(selection: $selectedHeroIndex) {
                    ForEach(Array(store.heroItems.enumerated()), id: \.element.id) { index, item in
                        CompactIOSHeroCard(
                            item: item,
                            isFavorite: store.isFavorite(item),
                            onPlay: { store.play(item) },
                            onFavorite: { store.toggleFavorite(item) }
                        )
                        .tag(index)
                    }
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif

                CompactHeroPager(
                    count: store.heroItems.count,
                    selection: selectedHeroIndex,
                    progress: pagerProgress
                )
                .padding(.bottom, 18)
            }
            .frame(height: heroHeight)
            .onAppear {
                store.selectedFeaturedItem = currentItem
            }
            .onChange(of: selectedHeroIndex) { _, newValue in
                store.selectedFeaturedItem = store.heroItems[newValue]
                pagerProgress = 0
            }
            .onReceive(heroTimer) { _ in
                guard store.heroItems.count > 1 else { return }
                withAnimation(.easeInOut(duration: 0.55)) {
                    selectedHeroIndex = (selectedHeroIndex + 1) % store.heroItems.count
                }
            }
            .onReceive(progressTimer) { _ in
                let step = 0.05 / 5.0
                if pagerProgress < 1.0 {
                    pagerProgress = min(1.0, pagerProgress + step)
                }
            }
        }
        .frame(height: 640)
    }

    private var currentItem: MediaItem {
        store.heroItems[min(selectedHeroIndex, max(store.heroItems.count - 1, 0))]
    }
}

struct CompactIOSHeroCard: View {
    let item: MediaItem
    let isFavorite: Bool
    let onPlay: () -> Void
    let onFavorite: () -> Void

    var body: some View {
        ZStack {
            CompactHeroBackdrop(item: item)

            LinearGradient(
                colors: [.clear, Color.black.opacity(0.18), Color.black.opacity(0.86)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                VStack(spacing: 14) {
                    Text(item.heroBadge)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(.black.opacity(0.28), in: Capsule())

                    heroTitle
                    metadataLine
                    actionRow
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 46)
            }
        }
    }

    private var heroTitle: some View {
        Text(item.title.uppercased())
            .font(.system(size: 46, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .minimumScaleFactor(0.68)
            .frame(maxWidth: .infinity)
    }

    private var metadataLine: some View {
        HStack(spacing: 10) {
            Image(systemName: "play.tv.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(.white.opacity(0.1), in: Circle())

            Text(item.contentType)
            Text("\u{2022}")
            Text(item.genres.first ?? "")
            if item.genres.count > 1 {
                Text("\u{2022}")
                Text(item.genres[1])
            }
            metadataBadge(text: item.rating)
        }
        .font(.headline)
        .foregroundStyle(.white.opacity(0.95))
        .frame(maxWidth: .infinity)
    }

    private func metadataBadge(text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .overlay {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(.white.opacity(0.92), lineWidth: 1.5)
            }
    }

    private var actionRow: some View {
        HStack(spacing: 12) {
            Button(action: onPlay) {
                Label("Play", systemImage: "play.fill")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
            }
            .background(.white, in: Capsule())

            Button(action: onFavorite) {
                Image(systemName: isFavorite ? "checkmark" : "plus")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(.white.opacity(0.16), in: Circle())
            }
        }
    }
}
