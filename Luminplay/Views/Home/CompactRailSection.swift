import LuminplayCore
import SwiftUI

struct CompactRailSection: View {
    let title: String
    let items: [MediaItem]
    let favorites: Set<UUID>
    let onSelect: (MediaItem) -> Void
    let onToggleFavorite: (MediaItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            NavigationLink {
                MediaListView(
                    title: title,
                    items: items,
                    favorites: favorites,
                    onSelect: onSelect,
                    onToggleFavorite: onToggleFavorite
                )
            } label: {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.black)
                    Image(systemName: "chevron.right")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 18)
            }
            .buttonStyle(.plain)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    Color.clear.frame(width: 2)
                    ForEach(items) { item in
                        NavigationLink {
                            MediaDetailView(
                                item: item,
                                isFavorite: favorites.contains(item.id),
                                onPlay: { onSelect(item) },
                                onToggleFavorite: { onToggleFavorite(item) }
                            )
                        } label: {
                            CompactPosterCard(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                    Color.clear.frame(width: 2)
                }
            }
            .scrollClipDisabled()
        }
    }
}

struct CompactPosterCard: View {
    let item: MediaItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(item.accent.gradient)
                .frame(width: 280, height: 158)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "play.tv.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(12)
                }
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(item.subtitle)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.88))
                    }
                    .padding(14)
                }

            Text(item.title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.black)
                .lineLimit(1)
        }
        .frame(width: 280, alignment: .leading)
    }
}
