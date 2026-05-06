import LuminplayCore
import SwiftUI

struct WatchQueueView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityProvider

    var body: some View {
        VStack(spacing: 20) {
            if let item = connectivity.nowPlayingItem {
                VStack(spacing: 6) {
                    Text("Up Next")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))

                    Text(item.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Text(item.durationText)
                        Text("\u{2022}")
                        Text(item.resolution)
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(item.accent.tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
            }

            if connectivity.browseItems.count > 1 {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Queue (\(connectivity.browseItems.count - 1) items)")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.5))

                    ForEach(Array(connectivity.browseItems.dropFirst().prefix(5))) { item in
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(item.accent.gradient)
                                .frame(width: 32, height: 20)
                            Text(item.title)
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 8)
    }
}
