import LuminplayCore
import SwiftUI

struct ChapterOverlay: View {
    let chapters: [Chapter]
    let currentPosition: TimeInterval
    let onSelectChapter: (Chapter) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Chapters")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

            Divider().background(.white.opacity(0.15))

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(chapters.enumerated()), id: \.element.id) { index, chapter in
                            Button {
                                onSelectChapter(chapter)
                            } label: {
                                HStack(spacing: 14) {
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(isCurrentChapter(index) ? Color.white : Color.white.opacity(0.15))
                                        .frame(width: 3, height: 44)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(chapter.title)
                                            .font(.headline.weight(.medium))
                                            .foregroundStyle(isCurrentChapter(index) ? .white : .white.opacity(0.7))
                                        Text(formatTime(chapter.startTime))
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.5))
                                    }
                                    Spacer()
                                    if isCurrentChapter(index) {
                                        Image(systemName: "play.fill")
                                            .font(.caption)
                                            .foregroundStyle(.white)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(isCurrentChapter(index) ? Color.white.opacity(0.08) : .clear)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .onAppear {
                    if let idx = chapters.firstIndex(where: { currentPosition < $0.endTime }) {
                        proxy.scrollTo(chapters[idx].id, anchor: .center)
                    }
                }
            }
        }
        .frame(width: 340, height: 440)
        .background(.black.opacity(0.82), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .luminplayGlassCard(cornerRadius: 24)
    }

    private func isCurrentChapter(_ index: Int) -> Bool {
        guard index < chapters.count else { return false }
        let chapter = chapters[index]
        return currentPosition >= chapter.startTime && currentPosition < chapter.endTime
    }

    private func formatTime(_ t: TimeInterval) -> String {
        let h = Int(t) / 3600
        let m = (Int(t) % 3600) / 60
        let s = Int(t) % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%d:%02d", m, s)
    }
}
