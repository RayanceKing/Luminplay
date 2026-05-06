import LuminplayCore
import SwiftUI

struct TransportControls: View {
    let isPlaying: Bool
    let position: TimeInterval
    let duration: TimeInterval
    let playbackRate: Float
    let audioTracks: [AudioTrack]
    let subtitleTracks: [SubtitleTrack]
    let chapters: [Chapter]
    let selectedAudioIndex: Int?
    let selectedSubtitleIndex: Int?
    let onPlayPause: () -> Void
    let onSeek: (TimeInterval) -> Void
    let onSkipForward: () -> Void
    let onSkipBackward: () -> Void
    let onSelectAudio: (Int) -> Void
    let onSelectSubtitle: (Int) -> Void
    let onSelectRate: (Float) -> Void
    let onSelectChapter: (Chapter) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                seekBar
                HStack(spacing: 20) {
                    skipBackButton
                    playPauseButton
                    skipForwardButton
                }
                bottomRow
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 20)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.5), .black.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }

    private var seekBar: some View {
        VStack(spacing: 6) {
            Slider(value: .init(
                get: { duration > 0 ? position / duration : 0 },
                set: { onSeek($0 * duration) }
            ))
            .tint(.white)

            HStack {
                Text(formatTime(position))
                Spacer()
                Text("-\(formatTime(max(duration - position, 0)))")
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(.white.opacity(0.7))
        }
    }

    private var playPauseButton: some View {
        Button(action: onPlayPause) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(.white.opacity(0.15), in: Circle())
        }
        .buttonStyle(.plain)
    }

    private var skipBackButton: some View {
        Button(action: onSkipBackward) {
            Image(systemName: "gobackward.10")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
        }
        .buttonStyle(.plain)
    }

    private var skipForwardButton: some View {
        Button(action: onSkipForward) {
            Image(systemName: "goforward.10")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
        }
        .buttonStyle(.plain)
    }

    private var bottomRow: some View {
        HStack(spacing: 16) {
            audioMenu
            subtitleMenu
            rateMenu
            if !chapters.isEmpty {
                chapterMenu
            }
            Spacer()
        }
    }

    private var audioMenu: some View {
        Menu {
            ForEach(Array(audioTracks.enumerated()), id: \.element.id) { index, track in
                Button {
                    onSelectAudio(index)
                } label: {
                    Label(track.label, systemImage: index == selectedAudioIndex ? "checkmark" : "speaker.wave.2")
                }
            }
        } label: {
            Image(systemName: "waveform")
                .font(.title3)
                .foregroundStyle(.white)
        }
        .disabled(audioTracks.isEmpty)
    }

    private var subtitleMenu: some View {
        Menu {
            Button {
                onSelectSubtitle(-1)
            } label: {
                Label("Off", systemImage: selectedSubtitleIndex == nil ? "checkmark" : "text.bubble")
            }
            ForEach(Array(subtitleTracks.enumerated()), id: \.element.id) { index, track in
                Button {
                    onSelectSubtitle(index)
                } label: {
                    Label(track.label, systemImage: index == selectedSubtitleIndex ? "checkmark" : "text.bubble")
                }
            }
        } label: {
            Image(systemName: "text.bubble")
                .font(.title3)
                .foregroundStyle(.white)
        }
    }

    private var rateMenu: some View {
        Menu {
            ForEach([0.5, 0.75, 1.0, 1.25, 1.5, 2.0], id: \.self) { rate in
                Button {
                    onSelectRate(Float(rate))
                } label: {
                    Label("\(rate, specifier: "%.2f")x", systemImage: abs(rate - Double(playbackRate)) < 0.01 ? "checkmark" : "")
                }
            }
        } label: {
            Text("\(playbackRate, specifier: "%.1f")x")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.white.opacity(0.12), in: Capsule())
        }
    }

    private var chapterMenu: some View {
        Button {
            onSelectChapter(chapters.first!)
        } label: {
            Image(systemName: "list.bullet.rectangle")
                .font(.title3)
                .foregroundStyle(.white)
        }
    }

    private func formatTime(_ t: TimeInterval) -> String {
        let h = Int(t) / 3600
        let m = (Int(t) % 3600) / 60
        let s = Int(t) % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%d:%02d", m, s)
    }
}
