import Foundation

public struct SubtitleTrack: Identifiable, Hashable {
    public let id = UUID()
    public let label: String
    public let language: String
    public let codec: String
    public let isForced: Bool
    public let isExternal: Bool
    public let deliveryURL: URL?

    public init(
        label: String,
        language: String,
        codec: String,
        isForced: Bool = false,
        isExternal: Bool = false,
        deliveryURL: URL? = nil
    ) {
        self.label = label
        self.language = language
        self.codec = codec
        self.isForced = isForced
        self.isExternal = isExternal
        self.deliveryURL = deliveryURL
    }
}
