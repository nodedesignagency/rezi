import Foundation
import SwiftUI

/// The Rezi mark at hero size, inside three rings that breathe outward.
///
/// The icon is the first screen's `AppIconBadge`, with its own arrival, just
/// larger. The rings ripple out after it lands, and from then on swell and
/// settle one after another, inside to out, so a slow pulse keeps passing away
/// from the icon.
struct IconHalo: View {
    var appeared: Bool
    /// Hero scale for the current screen.
    var scale: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var outerSize: CGFloat {
        (Metrics.Marquee.ringSizes.last ?? Metrics.Marquee.iconSize) * scale
    }

    var body: some View {
        ZStack {
            TimelineView(.animation(minimumInterval: nil, paused: reduceMotion)) { context in
                let time = context.date.timeIntervalSinceReferenceDate

                ZStack {
                    // Outermost first, so each ring's faint fill builds up
                    // toward the icon.
                    ForEach(Metrics.Marquee.ringSizes.indices.reversed(), id: \.self) { index in
                        ring(index: index, time: time)
                    }
                }
            }

            AppIconBadge(appeared: appeared, size: Metrics.Marquee.iconSize * scale)
        }
        .frame(width: outerSize, height: outerSize)
        .accessibilityHidden(true)
    }

    private func ring(index: Int, time: Double) -> some View {
        let size = Metrics.Marquee.ringSizes[index] * scale
        let shape = RoundedRectangle(
            cornerRadius: size * Metrics.Marquee.ringCornerRatio,
            style: .continuous
        )

        // Each ring peaks a moment after the one inside it.
        let wave = sin(
            time * Motion.Marquee.ringBreathSpeed
                - Double(index) * Motion.Marquee.ringBreathLag
        )
        let swell = reduceMotion ? 0 : CGFloat(wave + 1) / 2

        return shape
            .fill(Color.white.opacity(Metrics.Marquee.ringFillOpacity))
            .overlay {
                shape.strokeBorder(ReziColor.Marquee.ring, lineWidth: Metrics.Marquee.ringLineWidth)
            }
            .frame(width: size, height: size)
            .scaleEffect(1 + Metrics.Marquee.ringSwell * swell)
            .entrance(
                appeared,
                delay: Motion.Marquee.Beat.rings + Double(index) * Motion.Marquee.Beat.ringStagger,
                offsetY: 0,
                startScale: 0.82
            )
    }
}
