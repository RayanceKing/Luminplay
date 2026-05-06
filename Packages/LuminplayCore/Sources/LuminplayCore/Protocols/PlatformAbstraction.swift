import Foundation

// MARK: - Cross-Platform Abstraction Map

/*
 ## Platform Abstraction Layer

 This file documents the framework dependencies in LuminplayCore and maps them
 to equivalent APIs on future target platforms. The goal is to guide Android
 (Kotlin Multiplatform), Windows (.NET/WinUI), and Linux (Swift on Linux)
 implementation teams.

 ### Framework Dependencies in LuminplayCore

 | Apple Framework | Usage | Android Equivalent | Windows Equivalent | Linux Equivalent |
 |---|---|---|---|---|
 | Foundation | Networking, Codable, Date, UUID, UserDefaults | java.net / kotlinx.serialization / SharedPreferences | System.Net.Http / System.Text.Json | Foundation (swift-corelibs) |
 | SwiftUI (Color, LinearGradient) | ColorToken computed properties | Jetpack Compose (Brush, Color) | WinUI (SolidColorBrush, LinearGradientBrush) | GTK4 / Adwaita (GdkRGBA) |
 | Combine (ObservableObject) | LuminplayStore reactive state | Kotlin Flow / StateFlow | MVVM Toolkit ObservableObject | Combine (swift-corelibs) / custom |
 | Network (NWBrowser) | Bonjour server discovery | NsdManager (Android NSD) | DNS-SD (System.Net) | Avahi / D-Bus DNS-SD |
 | AVFoundation (AVPlayer) | Video playback | ExoPlayer / Media3 | MediaPlayer / VLC | mpv / GStreamer |
 | MediaPlayer | Now Playing Info | MediaSession | SystemMediaTransportControls | MPRIS (D-Bus) |
 | WatchConnectivity | Watch companion | Wear OS (MessageClient) | N/A (no watch) | N/A |

 ### Key Abstraction Points

 1. **PlayerBackend Protocol** — The central abstraction. AVPlayerBackend (Apple)
    and future mpv backend (cross-platform) both implement this. Any platform
    can provide its own backend.

 2. **ServerAdapter Protocol** — Already platform-agnostic. Uses URLSession
    (Foundation) which is available on all platforms via swift-corelibs.

 3. **HTTPClient** — Pure Foundation URLSession. Works on Linux (swift-corelibs),
    needs HTTPS stack on Android/Windows (platform-provided).

 4. **LuminplayStore** — ObservableObject, but the state management pattern
    (single source of truth) maps cleanly to ViewModel patterns on all platforms.

 5. **ColorToken** — The enum values (ember, cobalt, emerald, rose, amber) are
    semantic. Each platform renders them using its own gradient/color API.
    The computed properties (.gradient, .tint) are SwiftUI-specific and
    each platform provides its own extensions.

 ### Migration Strategy

 - **Phase A**: Extract LuminplayCore into a standalone Swift package that
   builds on Linux via swift-corelibs (no SwiftUI dependency in core types)
 - **Phase B**: Split ColorToken: keep enum in core, move gradient/tint to
   SwiftUI extension module
 - **Phase C**: Publish LuminplayCore as an SPM-compatible API contract that
   Kotlin/Flutter/.NET shells can call via platform channels
 - **Phase D**: Implement PlayerBackend with mpv on Linux, ExoPlayer on Android,
   and MediaPlayer on Windows

 ### Current Status
 - [x] Apple platforms: iOS 18.6, macOS 15.6, tvOS 18.0, watchOS 11.0, visionOS 2.0
 - [ ] Linux: Foundation + URLSession via swift-corelibs (no SwiftUI)
 - [ ] Android: Kotlin Multiplatform bridge to LuminplayCore API surface
 - [ ] Windows: WinUI host calling LuminplayCore via C interop or .NET bridge
*/
