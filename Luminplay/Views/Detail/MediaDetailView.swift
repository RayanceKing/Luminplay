import LuminplayCore
import SwiftUI

struct MediaDetailView: View {
    let item: MediaItem
    let isFavorite: Bool
    let onPlay: () -> Void
    let onToggleFavorite: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                posterSection

                VStack(alignment: .leading, spacing: 20) {
                    categoryRow
                    titleRow
                    descriptionRow
                    infoBadgeRow
                    actionButtons
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 60)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color.black)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onToggleFavorite()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundStyle(isFavorite ? .red : .white.opacity(0.8))
                }
            }
            #endif
        }
        #if os(iOS)
        .toolbarBackground(.hidden, for: .navigationBar)
        #endif
    }

    // MARK: - Poster

    private var posterSection: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 0, style: .continuous)
                .fill(item.accent.gradient)
                .frame(height: 420)
                .overlay {
                    Image(systemName: item.artworkSymbol)
                        .font(.system(size: 80, weight: .light))
                        .foregroundStyle(.white.opacity(0.25))
                }

            LinearGradient(
                colors: [.clear, .black.opacity(0.6), .black],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 10) {
                Text(item.heroBadge)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(.ultraThinMaterial, in: Capsule())

                Text(item.title)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Content rows

    private var categoryRow: some View {
        HStack(spacing: 8) {
            Text(item.contentType)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.7))

            ForEach(item.genres, id: \.self) { genre in
                Text("·")
                    .foregroundStyle(.white.opacity(0.4))
                Text(genre)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }

    private var titleRow: some View {
        Text(item.subtitle)
            .font(.title3.weight(.semibold))
            .foregroundStyle(.white)
    }

    private var descriptionRow: some View {
        Text(item.overview)
            .font(.body)
            .foregroundStyle(.white.opacity(0.8))
            .lineLimit(4)
    }

    private var infoBadgeRow: some View {
        HStack(spacing: 6) {
            Text(item.year)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))

            Text("·")
                .foregroundStyle(.white.opacity(0.3))

            Text(item.durationText)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))

            if !item.rating.isEmpty {
                Text("·")
                    .foregroundStyle(.white.opacity(0.3))
                RatingBadge(text: item.rating)
            }

            if item.resolution.contains("4K") {
                Text("·")
                    .foregroundStyle(.white.opacity(0.3))
                ResolutionBadge(text: "4K")
            }

            if item.audio.contains("Dolby") || item.audio.contains("Atmos") {
                Text("·")
                    .foregroundStyle(.white.opacity(0.3))
                AudioBadge(text: item.audio.contains("Atmos") ? "Atmos" : "Dolby")
            }

            Text("·")
                .foregroundStyle(.white.opacity(0.3))
            AccessibilityBadge(text: "CC")

            Text("·")
                .foregroundStyle(.white.opacity(0.3))
            AccessibilityBadge(text: "AD")
        }
    }

    // MARK: - Buttons

    private var actionButtons: some View {
        HStack(spacing: 14) {
            Button(action: onPlay) {
                Label("Play", systemImage: "play.fill")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            Button(action: onToggleFavorite) {
                Label(isFavorite ? "Favorited" : "Favorite", systemImage: isFavorite ? "heart.fill" : "heart")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            Button {} label: {
                Label("Trailer", systemImage: "film")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Info Badges

private struct RatingBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}

private struct ResolutionBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}

private struct AudioBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}

private struct AccessibilityBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.white.opacity(0.7))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .overlay {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .strokeBorder(.white.opacity(0.4), lineWidth: 1)
            }
    }
}
