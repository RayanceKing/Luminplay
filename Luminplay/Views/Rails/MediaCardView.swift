import LuminplayCore
import SwiftUI

struct MediaCardView: View {
    let item: MediaItem
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(item.accent.gradient)
                .frame(width: 300, height: 170)
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                        ProgressView(value: item.progress)
                            .tint(.white)
                            .opacity(item.progress == 0 ? 0 : 1)
                    }
                    .padding(16)
                }
                .overlay(alignment: .topTrailing) {
                    Button {
                        onToggleFavorite()
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.headline)
                            .frame(width: 38, height: 38)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .padding(12)
                    .luminplayGlassCard(cornerRadius: 18, interactive: true)
                    .padding(12)
                }

            Text(item.subtitle)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))

            Text(item.overview)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.68))
                .lineLimit(2)
        }
        .frame(width: 300, alignment: .leading)
    }
}
