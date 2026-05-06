import LuminplayCore
import SwiftUI

struct MediaRailSection: View {
    let title: String
    let subtitle: String
    let items: [MediaItem]
    let favorites: Set<UUID>
    let onSelect: (MediaItem) -> Void
    let onToggleFavorite: (MediaItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
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
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                        Image(systemName: "chevron.right")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .buttonStyle(.plain)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }

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
                            MediaCardView(
                                item: item,
                                isFavorite: favorites.contains(item.id),
                                onToggleFavorite: { onToggleFavorite(item) }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    Color.clear.frame(width: 2)
                }
                .padding(.vertical, 4)
            }
            .scrollClipDisabled()
        }
    }
}
