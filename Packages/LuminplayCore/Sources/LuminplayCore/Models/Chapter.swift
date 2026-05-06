import Foundation

public struct Chapter: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let startTime: TimeInterval
    public let endTime: TimeInterval

    public init(title: String, startTime: TimeInterval, endTime: TimeInterval) {
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
    }
}
