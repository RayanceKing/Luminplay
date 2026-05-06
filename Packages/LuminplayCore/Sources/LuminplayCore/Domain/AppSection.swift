import Foundation

public enum AppSection: String, CaseIterable, Identifiable {
    case home
    case library
    case devices
    case settings

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .home: "Home"
        case .library: "Library"
        case .devices: "Devices"
        case .settings: "Settings"
        }
    }

    public var systemImage: String {
        switch self {
        case .home: "play.tv.fill"
        case .library: "square.stack.3d.up.fill"
        case .devices: "externaldrive.connected.to.line.below.fill"
        case .settings: "gearshape.fill"
        }
    }
}
