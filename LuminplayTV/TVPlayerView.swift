import AVKit
import LuminplayCore
import SwiftUI

struct TVPlayerView: View {
    let item: MediaItem
    let streamURL: URL
    let onDismiss: () -> Void

    @State private var player: AVPlayer?

    var body: some View {
        VideoPlayer(player: player)
            .ignoresSafeArea()
            .onAppear {
                let avp = AVPlayer(url: streamURL)
                player = avp
                avp.play()
            }
            .onDisappear {
                player?.pause()
                player = nil
            }
            .onExitCommand {
                onDismiss()
            }
    }
}
