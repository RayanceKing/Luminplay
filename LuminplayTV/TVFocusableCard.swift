import LuminplayCore
import SwiftUI

struct TVFocusableCard: View {
    let item: MediaItem
    let isFavorite: Bool
    let onPlay: () -> Void
    let onFavorite: () -> Void

    @Environment(\.isFocused) private var isFocused

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(item.accent.gradient)
                .frame(width: cardWidth, height: cardHeight)
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                        if item.progress > 0 {
                            ProgressView(value: item.progress)
                                .tint(.white)
                                .frame(width: cardWidth * 0.7)
                        }
                    }
                    .padding(18)
                }
                .shadow(color: item.accent.tint.opacity(isFocused ? 0.5 : 0), radius: 20)

            Text(item.subtitle)
                .font(.callout)
                .foregroundStyle(.white.opacity(isFocused ? 1 : 0.7))
                .lineLimit(1)
        }
        .frame(width: cardWidth)
        .scaleEffect(isFocused ? 1.06 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
        .focusable(true)
        .onTapGesture {
            onPlay()
        }
        .onLongPressGesture {
            onFavorite()
        }
    }

    private var cardWidth: CGFloat { 360 }
    private var cardHeight: CGFloat { 202 }
}

// MARK: - Library

struct TVLibraryView: View {
    let store: LuminplayStore

    var body: some View {
        ZStack {
            LuminplayBackdrop(accent: .cobalt)
            VStack(alignment: .leading, spacing: 24) {
                Text("Library")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)

                Text("Server-backed media indexing with metadata enhancement and subtitle pipeline isolated outside the view layer.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(maxWidth: 800, alignment: .leading)

                Spacer()
            }
            .padding(90)
        }
    }
}
