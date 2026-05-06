import LuminplayCore
import SwiftUI

struct MediaListView: View {
    let title: String
    let items: [MediaItem]
    let favorites: Set<UUID>
    let onSelect: (MediaItem) -> Void
    let onToggleFavorite: (MediaItem) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(items) { item in
                Button {
                    onSelect(item)
                } label: {
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(item.accent.gradient)
                            .frame(width: 100, height: 56)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            Text(item.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.6))
                                .lineLimit(1)

                            HStack(spacing: 6) {
                                Text(item.year)
                                Text("·")
                                Text(item.durationText)
                                Text("·")
                                Text(item.rating)
                            }
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                        }

                        Spacer()

                        Button {
                            onToggleFavorite(item)
                        } label: {
                            Image(systemName: favorites.contains(item.id) ? "heart.fill" : "heart")
                                .font(.title3)
                                .foregroundStyle(favorites.contains(item.id) ? .red : .white.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 6)
                }
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(.white.opacity(0.1))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.black)
        .navigationTitle(title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                }
            }
            #endif
        }
    }
}
