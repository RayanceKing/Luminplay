import ClockKit
import LuminplayCore
import SwiftUI

struct ComplicationProvider {
    static func reloadActiveComplications() {
        let server = CLKComplicationServer.sharedInstance()
        for complication in server.activeComplications ?? [] {
            server.reloadTimeline(for: complication)
        }
    }

    static func templateForNowPlaying(
        item: MediaItem?,
        position: TimeInterval,
        duration: TimeInterval
    ) -> CLKComplicationTemplate {
        if let item = item, duration > 0 {
            let progress = Float(position / duration)
            let titleProvider = CLKSimpleTextProvider(text: item.title)
            let subtitleProvider = CLKSimpleTextProvider(text: item.subtitle)
            let ringProvider = CLKSimpleGaugeProvider(
                style: .ring,
                gaugeColor: .white,
                fillFraction: progress
            )

            return CLKComplicationTemplateGraphicCircularView(
                ComplicationRingView(
                    title: item.title,
                    progress: Double(progress)
                )
            )
        }

        let template = CLKComplicationTemplateGraphicCircularImage()
        template.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage())
        return template
    }
}

private struct ComplicationRingView: View {
    let title: String
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.15), lineWidth: 4)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(.white, style: .init(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(title.prefix(3).uppercased())
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}
