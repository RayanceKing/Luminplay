import LuminplayCore
import SwiftUI

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(.black.opacity(configuration.isPressed ? 0.22 : 0.12))
            .luminplayGlassCard(cornerRadius: 20, interactive: true)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}
