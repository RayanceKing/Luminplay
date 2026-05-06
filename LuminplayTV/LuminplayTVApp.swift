import LuminplayCore
import SwiftUI

@main
struct LuminplayTVApp: App {
    @StateObject private var store = LuminplayStore()

    var body: some Scene {
        WindowGroup {
            TVContentView()
                .environmentObject(store)
        }
    }
}
