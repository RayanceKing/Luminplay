import LuminplayCore
import SwiftUI

struct HeroShowcaseView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let store: LuminplayStore

    var body: some View {
        let item = store.selectedFeaturedItem

        VStack(alignment: .leading, spacing: 20) {
            heroHeader(for: item)
            platformStrip
        }
        .padding(heroPadding)
        .id(item.id)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.35), value: item.id)
    }

    @ViewBuilder
    private func heroHeader(for item: MediaItem) -> some View {
        if usesCompactHeroLayout {
            VStack(alignment: .leading, spacing: 20) {
                contentBlock(for: item)
                compactPosterSymbol(for: item)
            }
        } else {
            HStack(alignment: .top, spacing: 24) {
                contentBlock(for: item)
                Spacer(minLength: 0)
                posterSymbol(for: item)
            }
        }
    }

    @ViewBuilder
    private func contentBlock(for item: MediaItem) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(item.subtitle.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.82))

            Text(item.title)
                .font(heroTitleFont)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .lineLimit(usesCompactHeroLayout ? 2 : nil)
                .minimumScaleFactor(0.8)

            Text(item.overview)
                .font(.body)
                .foregroundStyle(.white.opacity(0.82))
                .frame(maxWidth: 620, alignment: .leading)

            metadataRow(for: item)
            actionBar(for: item)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func metadataRow(for item: MediaItem) -> some View {
        GlassRow {
            ForEach(item.genres, id: \.self) { genre in
                MetadataChip(title: genre, systemImage: "sparkle")
            }
            MetadataChip(title: item.resolution, systemImage: "4k.tv")
            MetadataChip(title: item.audio, systemImage: "waveform.badge.plus")
            MetadataChip(title: item.durationText, systemImage: "clock")
        }
    }

    @ViewBuilder
    private func actionBar(for item: MediaItem) -> some View {
        GlassRow {
            NavigationLink {
                MediaDetailView(
                    item: item,
                    isFavorite: store.isFavorite(item),
                    onPlay: { store.play(item) },
                    onToggleFavorite: { store.toggleFavorite(item) }
                )
            } label: {
                Label("Play", systemImage: "play.fill")
                    .frame(minWidth: 100)
            }
            .buttonStyle(PrimaryActionButtonStyle(accent: item.accent.tint))

            Button {
                store.toggleFavorite(item)
            } label: {
                Label(store.isFavorite(item) ? "Favorited" : "Favorite", systemImage: store.isFavorite(item) ? "heart.fill" : "heart")
            }
            .buttonStyle(SecondaryActionButtonStyle())

            Button {} label: {
                Label("Trailer", systemImage: "film")
            }
            .buttonStyle(SecondaryActionButtonStyle())
        }
    }

    @ViewBuilder
    private func posterSymbol(for item: MediaItem) -> some View {
        VStack(alignment: .trailing, spacing: 16) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(item.accent.gradient)
                .frame(width: posterWidth, height: posterWidth * 1.34)
                .overlay {
                    Image(systemName: item.artworkSymbol)
                        .font(.system(size: posterWidth * 0.26, weight: .medium))
                        .foregroundStyle(.white.opacity(0.95))
                }
                .overlay(alignment: .topTrailing) {
                    Text(item.year)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .padding(14)
                        .luminplayGlassCard(tint: .white.opacity(0.08), cornerRadius: 18)
                }

            Text("Direct Play Supported")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.74))
        }
    }

    @ViewBuilder
    private func compactPosterSymbol(for item: MediaItem) -> some View {
        HStack {
            Spacer(minLength: 0)
            posterSymbol(for: item)
            Spacer(minLength: 0)
        }
    }

    private var platformStrip: some View {
        GlassRow {
            ForEach([PlatformReadiness.ios, .macOS, .tvOS, .watchOS, .visionOS, .windows, .android]) { platform in
                Text("\(platform.title) \(platform.shortStatus)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .luminplayGlassCard(cornerRadius: 18)
            }
        }
    }

    private var heroPadding: CGFloat {
        #if os(visionOS)
        32
        #elseif os(macOS)
        28
        #else
        24
        #endif
    }

    private var posterWidth: CGFloat {
        #if os(visionOS)
        260
        #elseif os(macOS)
        240
        #else
        180
        #endif
    }

    private var heroTitleFont: Font {
        #if os(visionOS)
        .system(size: 54, weight: .bold, design: .rounded)
        #elseif os(macOS)
        .system(size: 48, weight: .bold, design: .rounded)
        #else
        .system(size: 40, weight: .bold, design: .rounded)
        #endif
    }

    private var usesCompactHeroLayout: Bool {
        #if os(iOS)
        horizontalSizeClass == .compact
        #else
        false
        #endif
    }
}
