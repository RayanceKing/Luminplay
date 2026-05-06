import LuminplayCore
import SwiftUI

struct LibraryIndexView: View {
    let store: LuminplayStore

    var body: some View {
        ZStack {
            LuminplayBackdrop(accent: .cobalt)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Library")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.white)

                    Text("Keep indexing, metadata enhancement, subtitle management, and playback engine outside the view layer. This is what makes future Windows and Android clients realistic rather than aspirational.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.76))
                        .frame(maxWidth: 760, alignment: .leading)

                    DevicesReadinessView(capabilities: store.deviceCapabilities.filter {
                        $0.readiness == .windows || $0.readiness == .android || $0.readiness == .tvOS || $0.readiness == .watchOS
                    })
                }
                .padding(24)
            }
        }
    }
}
