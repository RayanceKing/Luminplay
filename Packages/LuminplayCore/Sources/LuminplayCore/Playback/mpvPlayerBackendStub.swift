import Foundation

// MARK: - mpv Player Backend (Future Integration Stub)

/*
 ## mpv / FFmpeg Backend Integration Guide

 This stub documents the integration points for a future mpv-based
 PlayerBackend implementation. mpv provides full codec coverage, hardware
 decoding, HDR tone mapping, and subtitle rendering control beyond what
 AVPlayer offers natively.

 ### Dependencies
 - libmpv (C library) — built via FFmpeg + mpv configure
 - Swift-mpv binding or manual C interop via module map
 - FFmpeg libs: libavcodec, libavformat, libavutil, libswscale

 ### Key Integration Points

 1. **Initialization**
    ```swift
    let handle = mpv_create()
    mpv_initialize(handle)
    mpv_set_option_string(handle, "vo", "libmpv")
    mpv_set_option_string(handle, "hwdec", "videotoolbox")
    ```

 2. **Load Media**
    ```swift
    mpv_command(handle, ["loadfile", url.absoluteString])
    ```

 3. **Playback Control**
    ```swift
    mpv_set_property_string(handle, "pause", isPlaying ? "no" : "yes")
    mpv_command(handle, ["seek", String(position), "absolute"])
    ```

 4. **Property Observation** (position, duration, pause state)
    ```swift
    mpv_observe_property(handle, 0, "time-pos", MPV_FORMAT_DOUBLE)
    mpv_observe_property(handle, 0, "duration", MPV_FORMAT_DOUBLE)
    // Read via mpv_event_property in the event loop
    ```

 5. **Subtitle Rendering**
    - mpv handles embedded subtitles natively
    - External subtitles: mpv_command(handle, ["sub-add", subtitlePath])
    - Custom overlay: disable mpv subs, render via SubtitleOverlay.swift

 6. **Audio/Subtitle Track Selection**
    ```swift
    mpv_set_property_string(handle, "aid", trackID)
    mpv_set_property_string(handle, "sid", trackID)
    ```

 ### Platform-Specific Notes
 - **macOS/iOS/tvOS**: Videotoolbox hardware decoding
 - **Windows**: Direct3D11/DXVA2 via `vo=gpu`, `hwdec=d3d11va`
 - **Linux**: VAAPI/VDPAU via `vo=gpu`, `hwdec=vaapi`
 - **Android**: MediaCodec via `vo=gpu`, `hwdec=mediacodec`

 ### Transcoding Integration
 - mpv can play raw codec streams — the TranscodeEngine in this package
   decides whether to request a transcode from the server or direct play
 - For server-side transcode: pass the transcode stream URL to mpv
 - For direct play: pass the original file URL
*/

public final class MPVPlayerBackendStub: PlayerBackend, @unchecked Sendable {
    public let session: PlaybackSession
    public var currentPosition: TimeInterval { 0 }
    public var duration: TimeInterval { 0 }
    public var isPlaying: Bool { false }
    public var rate: Float = 1.0

    public init(session: PlaybackSession) {
        self.session = session
    }

    public func load(url: URL) async throws {
        // TODO: mpv_create + mpv_initialize + mpv_command loadfile
    }

    public func play() {}
    public func pause() {}
    public func seek(to position: TimeInterval) {}
    public func skipForward(_ seconds: TimeInterval) {}
    public func skipBackward(_ seconds: TimeInterval) {}
    public func stop() {}

    public func selectAudioTrack(_ track: AudioTrack) {}
    public func selectSubtitleTrack(_ track: SubtitleTrack?) {}
    public func setSubtitleCues(_ cues: [SubtitleCue]) {}

    public func setPositionCallback(_ callback: @escaping @Sendable (TimeInterval) -> Void) {}
    public func setDurationCallback(_ callback: @escaping @Sendable (TimeInterval) -> Void) {}
    public func setPlaybackStateCallback(_ callback: @escaping @Sendable (Bool) -> Void) {}
}
