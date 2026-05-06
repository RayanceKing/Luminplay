import Foundation

public enum PlatformReadiness: String, CaseIterable, Identifiable {
    case ios
    case macOS
    case tvOS
    case watchOS
    case visionOS
    case windows
    case android

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .ios: "iOS"
        case .macOS: "macOS"
        case .tvOS: "tvOS"
        case .watchOS: "watchOS"
        case .visionOS: "visionOS"
        case .windows: "Windows"
        case .android: "Android"
        }
    }

    public var shortStatus: String {
        switch self {
        case .ios, .macOS, .visionOS: "Shared UI"
        case .tvOS, .watchOS: "Target Ready"
        case .windows, .android: "Core Ready"
        }
    }
}
