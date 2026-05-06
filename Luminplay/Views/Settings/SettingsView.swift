import LuminplayCore
import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            LuminplayBackdrop(accent: .emerald)
            VStack(alignment: .leading, spacing: 16) {
                Text("Playback Architecture")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)

                Text("Recommended next: isolate server adapters, playback session state, offline cache strategy, and subtitle pipeline into shared services before adding tvOS and watchOS targets.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.76))
                    .frame(maxWidth: 720, alignment: .leading)

                VStack(alignment: .leading, spacing: 10) {
                    SettingsRow(title: "Server Adapters", detail: "Jellyfin, Emby, Plex, WebDAV, SMB")
                    SettingsRow(title: "Playback Backend", detail: "AVPlayer, custom subtitle compositor, future mpv/FFmpeg bridge")
                    SettingsRow(title: "State Sync", detail: "Watch history, scrobble, continue watching, multi-user profiles")
                    SettingsRow(title: "Client Surfaces", detail: "Touch, pointer, remote, wrist remote, spatial cinema")
                }
                .padding(20)
                .background(.black.opacity(0.16))
                .luminplayGlassCard(cornerRadius: 28)

                Spacer()
            }
            .padding(24)
        }
    }
}

struct SettingsRow: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.72))
        }
    }
}
