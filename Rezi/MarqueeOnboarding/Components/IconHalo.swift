import Foundation
import SwiftUI

/// The Rezi mark at hero size, pulsing.
///
/// The icon is the first screen's `AppIconBadge`, with its own arrival, just
/// larger. Its three rings are the pulse itself: each is born at the icon's
/// edge, grows outward and fades away, then starts again. They are spread
/// evenly through that cycle, so one is always leaving the icon as another
/// fades, and at any moment there are three around it, as in the design,
/// none of them standing still.
///
/// With Reduce Motion on, the design's three rings are shown at rest.
struct IconHalo: View {
    var appeared: Bool
    /// Hero scale for the current screen.
    var scale: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// The pulse is measured from here.
    @State private var startTime = Date.timeIntervalSinceReferenceDate

    /// The layout box is the design's outer ring, which the page positions
    /// by. Rings growing past it are drawn outside it.
    private var outerSize: CGFloat {
        (Metrics.Marquee.ringSizes.last ?? Metrics.Marquee.iconSize) * scale
    }

    var body: some View {
        ZStack {
            TimelineView(.animation(minimumInterval: nil, paused: reduceMotion)) { context in
                let elapsed = context.date.timeIntervalSinceReferenceDate - startTime

                ZStack {
                    ForEach(Metrics.Marquee.ringSizes.indices, id: \.self) { index in
                        ringView(reduceMotion ? Self.restingRing(index) : Self.pulsingRing(index, elapsed: elapsed))
                    }
                }
            }
            .entrance(appeared, delay: Motion.Marquee.Beat.rings, offsetY: 0, startScale: 0.82)

            // Above the rings, so each is hidden behind the icon as it is born.
            AppIconBadge(appeared: appeared, size: Metrics.Marquee.iconSize * scale)
        }
        .frame(width: outerSize, height: outerSize)
        .accessibilityHidden(true)
    }

    // MARK: - Rings

    /// One ring at one moment, in design points.
    private struct Ring {
        var size: CGFloat
        var strokeOpacity: Double
        var fillOpacity: Double
    }

    private func ringView(_ ring: Ring) -> some View {
        let size = ring.size * scale
        let shape = RoundedRectangle(
            cornerRadius: size * Metrics.Marquee.ringCornerRatio,
            style: .continuous
        )

        return shape
            .fill(Color.white.opacity(ring.fillOpacity))
            .overlay {
                shape.strokeBorder(
                    ReziColor.Marquee.ring.opacity(ring.strokeOpacity),
                    lineWidth: Metrics.Marquee.ringLineWidth
                )
            }
            .frame(width: size, height: size)
    }

    /// The design's ring, standing still.
    private static func restingRing(_ index: Int) -> Ring {
        Ring(
            size: Metrics.Marquee.ringSizes[index],
            strokeOpacity: Metrics.Marquee.ringStrokeOpacity,
            fillOpacity: Metrics.Marquee.ringFillOpacity
        )
    }

    /// Where ring `index` is in its life, `elapsed` seconds in.
    private static func pulsingRing(_ index: Int, elapsed: Double) -> Ring {
        let count = Double(Metrics.Marquee.ringSizes.count)
        let cycles = elapsed / Motion.Marquee.pulseLife + Double(index) / count
        let wrapped = cycles.truncatingRemainder(dividingBy: 1)
        let life = wrapped < 0 ? wrapped + 1 : wrapped

        // Quick off the icon, easing as it spreads.
        let travel = 1 - pow(1 - life, 1.3)
        let size = Metrics.Marquee.iconSize
            + (Metrics.Marquee.pulseMaxSize - Metrics.Marquee.iconSize) * CGFloat(travel)

        // Fades in while still mostly behind the icon, then out as it grows,
        // reaching nothing just as it is reborn.
        let fadeIn = Motion.Marquee.pulseFadeIn
        let strength = life < fadeIn
            ? life / fadeIn
            : pow(1 - (life - fadeIn) / (1 - fadeIn), 1.2)

        return Ring(
            size: size,
            strokeOpacity: Metrics.Marquee.pulseStrokeOpacity * strength,
            fillOpacity: Metrics.Marquee.ringFillOpacity * strength
        )
    }
}
