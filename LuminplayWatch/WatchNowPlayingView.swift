import LuminplayCore
import SwiftUI

struct WatchNowPlayingView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityProvider

    var body: some View {
        VStack(spacing: 10) {
            if let item = connectivity.nowPlayingItem {
                Circle()
                    .fill(item.accent.gradient)
                    .frame(width: 120, height: 120)
                    .overlay {
                        Image(systemName: item.artworkSymbol)
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                    }

                Text(item.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                Text(item.subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)

                ProgressView(value: connectivity.nowPlayingDuration > 0
                    ? connectivity.nowPlayingPosition / connectivity.nowPlayingDuration : 0)
                    .tint(.white)
                    .frame(height: 4)

                HStack(spacing: 6) {
                    Text(formatTime(connectivity.nowPlayingPosition))
                    Spacer()
                    Text("-\(formatTime(max(connectivity.nowPlayingDuration - connectivity.nowPlayingPosition, 0)))")
                }
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.white.opacity(0.5))
                .padding(.horizontal, 8)

                HStack(spacing: 16) {
                    Button {
                        connectivity.sendSkipBackward()
                    } label: {
                        Image(systemName: "gobackward.10")
                            .font(.title3)
                    }

                    Button {
                        if connectivity.isPlaying {
                            connectivity.sendPauseCommand()
                        } else {
                            connectivity.sendPlayCommand()
                        }
                    } label: {
                        Image(systemName: connectivity.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title)
                            .frame(width: 44, height: 44)
                            .background(.white.opacity(0.15), in: Circle())
                    }

                    Button {
                        connectivity.sendSkipForward()
                    } label: {
                        Image(systemName: "goforward.10")
                            .font(.title3)
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "play.tv.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white.opacity(0.3))
                    Text("No Playback")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.5))
                    Text("Open Luminplay on iPhone")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
        }
        .padding(.horizontal, 8)
    }

    private func formatTime(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }
}
