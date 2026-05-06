import LuminplayCore
import SwiftUI

struct DevicesReadinessView: View {
    let capabilities: [DeviceCapability]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Platform Readiness")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)

            LazyVGrid(columns: gridColumns, spacing: 14) {
                ForEach(capabilities) { capability in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: capability.icon)
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                            Text(capability.readiness.title)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.84))
                        }

                        Text(capability.title)
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text(capability.detail)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.72))
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, minHeight: 146, alignment: .topLeading)
                    .background(.black.opacity(0.14))
                    .luminplayGlassCard(cornerRadius: 24)
                }
            }
        }
    }

    private var gridColumns: [GridItem] {
        #if os(macOS) || os(visionOS)
        Array(repeating: GridItem(.flexible(minimum: 220), spacing: 14), count: 3)
        #else
        [GridItem(.flexible(minimum: 160), spacing: 14)]
        #endif
    }
}
