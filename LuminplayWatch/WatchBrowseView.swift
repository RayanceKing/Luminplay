import LuminplayCore
import SwiftUI

struct WatchBrowseView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityProvider

    var body: some View {
        List {
            if connectivity.browseItems.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "square.stack.3d.up")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.3))
                    Text("No Items")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            } else {
                ForEach(connectivity.browseItems) { item in
                    Button {
                        connectivity.sendPlayItem(item)
                    } label: {
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(item.accent.gradient)
                                .frame(width: 44, height: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                Text(item.subtitle)
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white.opacity(0.5))
                                    .lineLimit(1)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listStyle(.plain)
        .onAppear {
            connectivity.requestBrowseItems()
        }
    }
}
