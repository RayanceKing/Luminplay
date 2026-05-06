import Combine
import LuminplayCore
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: LuminplayStore

    var body: some View {
        AppShellView(store: store)
            .modifier(PlayerPresentationModifier(store: store))
    }
}

private struct PlayerPresentationModifier: ViewModifier {
    @ObservedObject var store: LuminplayStore

    func body(content: Content) -> some View {
        #if os(macOS)
        content.sheet(isPresented: $store.isShowingPlayer) {
            if let url = store.playbackURL {
                PlayerView(
                    item: store.selectedFeaturedItem,
                    streamURL: url,
                    sessionManager: store.sessionManager,
                    onDismiss: { store.dismissPlayer() }
                )
                .frame(minWidth: 900, minHeight: 550)
            }
        }
        #else
        content.fullScreenCover(isPresented: $store.isShowingPlayer) {
            if let url = store.playbackURL {
                PlayerView(
                    item: store.selectedFeaturedItem,
                    streamURL: url,
                    sessionManager: store.sessionManager,
                    onDismiss: { store.dismissPlayer() }
                )
            }
        }
        #endif
    }
}

#Preview {
    ContentView()
        .environmentObject(LuminplayStore())
}
