import LuminplayCore
import SwiftUI

struct WatchContentView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityProvider

    var body: some View {
        TabView {
            WatchNowPlayingView()
            WatchBrowseView()
            WatchQueueView()
        }
        .tabViewStyle(.verticalPage)
        .onAppear {
            connectivity.requestNowPlaying()
            connectivity.requestBrowseItems()
        }
    }
}
