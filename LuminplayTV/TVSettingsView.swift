import LuminplayCore
import SwiftUI

struct TVSettingsView: View {
    var body: some View {
        ZStack {
            LuminplayBackdrop(accent: .emerald)
            VStack(alignment: .leading, spacing: 32) {
                Text("Settings")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 20) {
                    TVSettingsRow(
                        title: "Server Adapters",
                        detail: "Connect to Jellyfin, Emby, Plex, or browse SMB/WebDAV shares."
                    )
                    TVSettingsRow(
                        title: "Playback Quality",
                        detail: "Direct play when possible. Transcode orchestration for incompatible codecs."
                    )
                    TVSettingsRow(
                        title: "Subtitles",
                        detail: "Auto-select preferred language. Offset adjustment. External subtitle loading."
                    )
                    TVSettingsRow(
                        title: "Audio",
                        detail: "Default audio track selection. Surround sound passthrough."
                    )
                }
                .frame(maxWidth: 900)

                Spacer()
            }
            .padding(90)
        }
    }
}

private struct TVSettingsRow: View {
    let title: String
    let detail: String

    @Environment(\.isFocused) private var isFocused

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(isFocused ? .white : .white.opacity(0.8))
            Text(detail)
                .font(.body)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isFocused ? .white.opacity(0.12) : .white.opacity(0.05))
        )
        .scaleEffect(isFocused ? 1.03 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
        .focusable()
    }
}
