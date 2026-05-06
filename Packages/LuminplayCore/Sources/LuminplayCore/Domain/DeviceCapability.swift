import Foundation

public struct DeviceCapability: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let detail: String
    public let icon: String
    public let readiness: PlatformReadiness

    public init(title: String, detail: String, icon: String, readiness: PlatformReadiness) {
        self.title = title
        self.detail = detail
        self.icon = icon
        self.readiness = readiness
    }
}
