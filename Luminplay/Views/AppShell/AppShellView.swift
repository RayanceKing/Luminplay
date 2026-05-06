import LuminplayCore
import SwiftUI

struct AppShellView: View {
    @ObservedObject var store: LuminplayStore

    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            SidebarView(selectedSection: $store.selectedSection)
                .navigationSplitViewColumnWidth(min: 220, ideal: 250)
        } detail: {
            MainStageView(store: store)
        }
        #else
        TabView(selection: $store.selectedSection) {
            Tab(AppSection.home.title, systemImage: AppSection.home.systemImage, value: .home) {
                MainStageView(store: store)
            }
            Tab(AppSection.library.title, systemImage: AppSection.library.systemImage, value: .library) {
                LibraryIndexView(store: store)
            }
            Tab(AppSection.devices.title, systemImage: AppSection.devices.systemImage, value: .devices) {
                DevicesReadinessView(capabilities: store.deviceCapabilities)
            }
            Tab(AppSection.settings.title, systemImage: AppSection.settings.systemImage, value: .settings) {
                SettingsView()
            }
        }
        #endif
    }
}
