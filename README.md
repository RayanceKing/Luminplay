# Luminplay

Luminplay is being shaped as a private theater player with Apple TV app sensibilities and Infuse-style capabilities:

- shared SwiftUI shell for `iOS`, `macOS`, and `visionOS`
- target-ready seams for `tvOS` and `watchOS`
- domain contracts prepared for future `Windows` and `Android` clients
- Liquid Glass presentation on Apple platforms that support the iOS 26-era design system

## What this prototype covers

- cinematic home surface with hero, rails, and playback calls to action
- shared media domain model instead of template `Item` data
- protocol seams for library, playback, and sync providers
- platform readiness dashboard to keep future targets explicit

## Recommended next milestones

1. Split `LibraryProviding` into real server adapters: Jellyfin, Plex, Emby, SMB/WebDAV.
2. Add a playback session core that owns audio, subtitle, chapter, and resume state.
3. Create a dedicated `tvOS` app target with focus-first rails and transport overlays.
4. Create a `watchOS` companion target for remote control and Now Playing handoff.
5. Move the shared domain and service layer into a reusable package before starting Windows or Android clients.
