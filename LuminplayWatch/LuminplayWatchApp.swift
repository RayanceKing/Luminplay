import LuminplayCore
import SwiftUI
import WatchConnectivity

@main
struct LuminplayWatchApp: App {
    @StateObject private var connectivity = WatchConnectivityProvider()

    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(connectivity)
        }
    }
}
