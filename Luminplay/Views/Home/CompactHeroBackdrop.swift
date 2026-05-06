import LuminplayCore
import SwiftUI

struct CompactHeroBackdrop: View {
    let item: MediaItem

    var body: some View {
        switch item.heroArtworkStyle {
        case .solar:
            solarBackdrop
        case .gala:
            galaBackdrop
        case .aurora:
            auroraBackdrop
        case .noir:
            noirBackdrop
        }
    }

    private var solarBackdrop: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.18, green: 0.09, blue: 0.04), Color(red: 0.95, green: 0.73, blue: 0.30)], startPoint: .topLeading, endPoint: .bottomTrailing)

            Circle()
                .fill(Color(red: 1.0, green: 0.90, blue: 0.55))
                .frame(width: 250, height: 250)
                .blur(radius: 8)
                .offset(x: 150, y: -40)

            Image(systemName: "figure.outdoor.cycle")
                .font(.system(size: 150, weight: .light))
                .foregroundStyle(.black.opacity(0.48))
                .offset(x: 70, y: 40)

            Rectangle()
                .fill(
                    LinearGradient(colors: [.clear, Color.black.opacity(0.42), Color.black.opacity(0.85)], startPoint: .top, endPoint: .bottom)
                )
        }
    }

    private var galaBackdrop: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.79, green: 0.58, blue: 0.50), Color(red: 0.22, green: 0.07, blue: 0.05)], startPoint: .top, endPoint: .bottom)

            VStack(spacing: 26) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.white.opacity(0.72))
                        .frame(height: 6)
                        .padding(.horizontal, -10)
                }
            }
            .offset(y: -120)
            .blur(radius: 4)

            HStack(spacing: 18) {
                Circle().fill(Color.black.opacity(0.32)).frame(width: 120, height: 120)
                Circle().fill(Color.black.opacity(0.16)).frame(width: 148, height: 148)
                Circle().fill(Color.black.opacity(0.26)).frame(width: 128, height: 128)
            }
            .offset(y: 90)

            Rectangle()
                .fill(
                    LinearGradient(colors: [.clear, Color.black.opacity(0.28), Color.black.opacity(0.82)], startPoint: .top, endPoint: .bottom)
                )
        }
    }

    private var auroraBackdrop: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.03, green: 0.08, blue: 0.18), Color(red: 0.06, green: 0.25, blue: 0.42), Color(red: 0.20, green: 0.72, blue: 0.65)], startPoint: .topLeading, endPoint: .bottomTrailing)

            Circle()
                .fill(Color(red: 0.36, green: 0.90, blue: 0.86).opacity(0.48))
                .frame(width: 320, height: 320)
                .blur(radius: 40)
                .offset(x: 120, y: -80)

            Image(systemName: "sparkles")
                .font(.system(size: 160, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.14))
                .offset(y: 10)

            Rectangle()
                .fill(
                    LinearGradient(colors: [.clear, Color.black.opacity(0.20), Color.black.opacity(0.84)], startPoint: .top, endPoint: .bottom)
                )
        }
    }

    private var noirBackdrop: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.06, green: 0.07, blue: 0.09), Color(red: 0.12, green: 0.17, blue: 0.24)], startPoint: .topLeading, endPoint: .bottomTrailing)

            VStack(spacing: 18) {
                ForEach(0..<6, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white.opacity(0.07))
                        .frame(height: 38)
                }
            }
            .padding(.horizontal, 40)
            .offset(y: -70)

            Rectangle()
                .fill(
                    LinearGradient(colors: [.clear, Color.black.opacity(0.22), Color.black.opacity(0.88)], startPoint: .top, endPoint: .bottom)
                )
        }
    }
}
