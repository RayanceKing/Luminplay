import Foundation

public struct AudioTrack: Identifiable, Hashable {
    public let id = UUID()
    public let label: String
    public let language: String
    public let codec: String
    public let channels: Int
    public let isDefault: Bool

    public init(
        label: String,
        language: String,
        codec: String,
        channels: Int,
        isDefault: Bool = false
    ) {
        self.label = label
        self.language = language
        self.codec = codec
        self.channels = channels
        self.isDefault = isDefault
    }
}
