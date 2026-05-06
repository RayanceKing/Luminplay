import LuminplayCore
import SwiftUI

struct SidebarView: View {
    @Binding var selectedSection: AppSection

    var body: some View {
        sidebarList
            .navigationTitle("Luminplay")
    }

    @ViewBuilder
    private var sidebarList: some View {
        #if os(macOS)
        List(AppSection.allCases, selection: $selectedSection) { section in
            Label(section.title, systemImage: section.systemImage)
                .tag(section)
        }
        .listStyle(.sidebar)
        #else
        List(AppSection.allCases) { section in
            Label(section.title, systemImage: section.systemImage)
        }
        #endif
    }
}
