import LuminplayCore
import SwiftUI

struct MetadataChip: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.medium))
            .foregroundStyle(.white.opacity(0.92))
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .luminplayGlassCard(cornerRadius: 18)
    }
}
