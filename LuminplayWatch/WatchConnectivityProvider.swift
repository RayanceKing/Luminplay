import Combine
import LuminplayCore
import WatchConnectivity

@MainActor
final class WatchConnectivityProvider: NSObject, ObservableObject {
    @Published var isReachable = false
    @Published var nowPlayingItem: MediaItem?
    @Published var nowPlayingPosition: TimeInterval = 0
    @Published var nowPlayingDuration: TimeInterval = 0
    @Published var isPlaying = false
    @Published var browseItems: [MediaItem] = []

    private let session: WCSession

    override init() {
        session = .default
        super.init()
        session.delegate = self
        session.activate()
    }

    func sendPlayCommand() {
        send(["command": "play"])
    }

    func sendPauseCommand() {
        send(["command": "pause"])
    }

    func sendPlayItem(_ item: MediaItem) {
        send(["command": "playItem", "itemId": item.id.uuidString])
    }

    func sendSeekCommand(to position: TimeInterval) {
        send(["command": "seek", "position": position])
    }

    func sendSkipForward() {
        send(["command": "skipForward", "seconds": 10])
    }

    func sendSkipBackward() {
        send(["command": "skipBackward", "seconds": 10])
    }

    func requestBrowseItems() {
        send(["command": "fetchBrowse"])
    }

    func requestNowPlaying() {
        send(["command": "fetchNowPlaying"])
    }

    private func send(_ message: [String: Any]) {
        guard session.isReachable else { return }
        session.sendMessage(message, replyHandler: nil) { error in
            print("WatchConnectivity error: \(error)")
        }
    }
}

extension WatchConnectivityProvider: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            isReachable = session.isReachable
            if session.isReachable {
                requestNowPlaying()
                requestBrowseItems()
            }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in
            switch message["type"] as? String {
            case "nowPlaying":
                if let data = message["item"] as? Data,
                   let item = try? JSONDecoder().decode(MediaItem.self, from: data) {
                    nowPlayingItem = item
                }
                nowPlayingPosition = message["position"] as? TimeInterval ?? 0
                nowPlayingDuration = message["duration"] as? TimeInterval ?? 0
                isPlaying = message["isPlaying"] as? Bool ?? false

            case "browseItems":
                if let data = message["items"] as? Data,
                   let items = try? JSONDecoder().decode([MediaItem].self, from: data) {
                    browseItems = items
                }

            default:
                break
            }
        }
    }
}
