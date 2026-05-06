import LuminplayCore
import SwiftUI

struct SubtitleOverlay: View {
    let cues: [SubtitleCue]
    let position: TimeInterval
    let offset: TimeInterval

    var body: some View {
        VStack {
            Spacer()
            if let cue = activeCue {
                Text(cue.text)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .shadow(color: .black.opacity(0.6), radius: 4, y: 2)
                    .padding(.bottom, 60)
                    .padding(.horizontal, 40)
                    .transition(.opacity.animation(.easeInOut(duration: 0.15)))
            }
        }
        .animation(.easeInOut(duration: 0.15), value: activeCue?.id)
    }

    private var activeCue: SubtitleCue? {
        let adjustedPosition = position + offset
        return cues.first { adjustedPosition >= $0.start && adjustedPosition < $0.end }
    }
}
