import Foundation

public struct TranscodeEngine {
    public enum Decision: Equatable {
        case directPlay
        case directStream(container: String)
        case transcode(videoCodec: String, audioCodec: String, maxBitrate: Int?)
    }

    private let deviceCapabilities: DeviceCodecCapability

    public init(deviceCapabilities: DeviceCodecCapability = .current) {
        self.deviceCapabilities = deviceCapabilities
    }

    public func decide(
        videoCodec: String,
        audioCodec: String,
        container: String,
        bitrate: Int,
        maxWidth: Int? = nil,
        maxHeight: Int? = nil
    ) -> Decision {
        if deviceCapabilities.canDirectPlay(videoCodec: videoCodec)
            && deviceCapabilities.canDirectPlay(audioCodec: audioCodec)
            && deviceCapabilities.canDirectPlay(container: container) {
            return .directPlay
        }

        if deviceCapabilities.canDirectPlay(videoCodec: videoCodec)
            && deviceCapabilities.canDirectPlay(audioCodec: audioCodec) {
            return .directStream(container: "mp4")
        }

        return .transcode(
            videoCodec: deviceCapabilities.preferredVideoCodec,
            audioCodec: deviceCapabilities.preferredAudioCodec,
            maxBitrate: deviceCapabilities.estimateBitrate(for: maxWidth ?? 1920, height: maxHeight ?? 1080, originalBitrate: bitrate)
        )
    }
}

public struct DeviceCodecCapability: Sendable {
    public let supportedVideoCodecs: Set<String>
    public let supportedAudioCodecs: Set<String>
    public let supportedContainers: Set<String>
    public let preferredVideoCodec: String
    public let preferredAudioCodec: String
    public let maxResolution: (width: Int, height: Int)
    public let maxBitrate: Int

    public static let current: DeviceCodecCapability = {
        #if os(tvOS)
        DeviceCodecCapability(
            supportedVideoCodecs: ["h264", "hevc", "mpeg4"],
            supportedAudioCodecs: ["aac", "ac3", "eac3", "mp3"],
            supportedContainers: ["mp4", "mov", "m4v", "mp3", "aac"],
            preferredVideoCodec: "h264",
            preferredAudioCodec: "aac",
            maxResolution: (3840, 2160),
            maxBitrate: 40_000_000
        )
        #elseif os(watchOS)
        DeviceCodecCapability(
            supportedVideoCodecs: ["h264", "hevc"],
            supportedAudioCodecs: ["aac", "mp3"],
            supportedContainers: ["mp4", "mov", "m4v"],
            preferredVideoCodec: "h264",
            preferredAudioCodec: "aac",
            maxResolution: (448, 368),
            maxBitrate: 2_000_000
        )
        #else
        DeviceCodecCapability(
            supportedVideoCodecs: ["h264", "hevc", "mpeg4", "vp9", "av1"],
            supportedAudioCodecs: ["aac", "ac3", "eac3", "mp3", "flac", "opus"],
            supportedContainers: ["mp4", "mov", "m4v", "mkv", "webm", "mp3", "flac"],
            preferredVideoCodec: "hevc",
            preferredAudioCodec: "aac",
            maxResolution: (3840, 2160),
            maxBitrate: 80_000_000
        )
        #endif
    }()

    public func canDirectPlay(videoCodec: String) -> Bool {
        supportedVideoCodecs.contains(videoCodec.lowercased())
    }

    public func canDirectPlay(audioCodec: String) -> Bool {
        supportedAudioCodecs.contains(audioCodec.lowercased())
    }

    public func canDirectPlay(container: String) -> Bool {
        supportedContainers.contains(container.lowercased())
    }

    public func estimateBitrate(for width: Int, height: Int, originalBitrate: Int) -> Int {
        let resolutionRatio = Double(width * height) / Double(maxResolution.width * maxResolution.height)
        let estimated = Int(Double(originalBitrate) * resolutionRatio)
        return min(estimated, maxBitrate)
    }
}
