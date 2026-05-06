import SwiftUI

struct CompactHeroPager: View {
    let count: Int
    let selection: Int
    let progress: Double

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<count, id: \.self) { index in
                let distance = abs(index - selection)
                let scale = CGFloat(max(0.4, 1.0 - Double(distance) * 0.3))
                let opacity = Double(max(0.35, 1.0 - Double(distance) * 0.35))

                if index == selection {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.white.opacity(0.3))
                                .frame(width: 28, height: 8)

                            Capsule()
                                .fill(.white)
                                .frame(width: max(8, 28 * CGFloat(progress)), height: 8)
                        }
                    }
                    .frame(width: 28, height: 8)
                } else {
                    Circle()
                        .fill(.white.opacity(opacity))
                        .frame(width: 8 * scale, height: 8 * scale)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selection)
    }
}
