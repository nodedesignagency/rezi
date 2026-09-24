import Foundation
import SwiftUI

/// The Rezi mark at hero size, inside three rings, pulsing.
///
/// The icon is the first screen's `AppIconBadge`, with its own arrival, just
/// larger. The rings ripple out after it lands. From then on, every couple of
/// seconds the icon gives a small beat and a faint ring leaves it, travelling
/// out through the other three; each lights up and swells as it passes, so the
/// pulse reads as moving outward rather than everything flashing at once.
struct IconHalo: View {
    var appeared: Bool
    /// Hero scale for the current screen.
    var scale: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// When the first pulse leaves, once the entrance has settled.
    @State private var pulseStart: TimeInterval?

    private var outerSize: CGFloat {
        (Metrics.Marquee.ringSizes.last ?? Metrics.Marquee.iconSize) * scale
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: nil, paused: reduceMotion)) { context in
            let pulse = currentPulse(at: context.date.timeIntervalSinceReferenceDate)

            ZStack {
                if let pulse {
                    travellingRing(pulse)
                }

                // Outermost first, so each ring's faint fill builds up
                // toward the icon.
                ForEach(Metrics.Marquee.ringSizes.indices.reversed(), id: \.self) { index in
                    ring(index: index, pulse: pulse)
                }

                AppIconBadge(appeared: appeared, size: Metrics.Marquee.iconSize * scale)
                    .scaleEffect(1 + Metrics.Marquee.pulseBeatScale * (pulse?.beat ?? 0))
            }
        }
        .frame(width: outerSize, height: outerSize)
        .onAppear(perform: schedulePulse)
        .onChange(of: appeared) { schedulePulse() }
        .accessibilityHidden(true)
    }

    // MARK: - Rings

    private func ring(index: Int, pulse: Pulse?) -> some View {
        let designSize = Metrics.Marquee.ringSizes[index]
        let size = designSize * scale
        let lit = pulse?.light(at: designSize) ?? 0
        let shape = RoundedRectangle(
            cornerRadius: size * Metrics.Marquee.ringCornerRatio,
            style: .continuous
        )

        return shape
            .fill(Color.white.opacity(
                Metrics.Marquee.ringFillOpacity + Metrics.Marquee.pulseFillGain * Double(lit)
            ))
            .overlay {
                shape.strokeBorder(
                    ReziColor.Marquee.ring.opacity(
                        Metrics.Marquee.ringStrokeOpacity + Metrics.Marquee.pulseStrokeGain * Double(lit)
                    ),
                    lineWidth: Metrics.Marquee.ringLineWidth
                )
            }
            .frame(width: size, height: size)
            .scaleEffect(1 + Metrics.Marquee.pulseSwell * lit)
            .entrance(
                appeared,
                delay: Motion.Marquee.Beat.rings + Double(index) * Motion.Marquee.Beat.ringStagger,
                offsetY: 0,
                startScale: 0.82
            )
    }

    /// The faint ring on its way out from the icon.
    private func travellingRing(_ pulse: Pulse) -> some View {
        let size = pulse.size * scale

        return RoundedRectangle(
            cornerRadius: size * Metrics.Marquee.ringCornerRatio,
            style: .continuous
        )
        .strokeBorder(ReziColor.Marquee.ring, lineWidth: Metrics.Marquee.pulseLineWidth)
        .frame(width: size, height: size)
        .opacity(pulse.opacity)
    }

    // MARK: - Pulse

    /// One moment of a pulse.
    private struct Pulse {
        /// Size of the travelling ring, in design points.
        var size: CGFloat
        /// Its opacity; zero while resting between pulses.
        var opacity: Double
        /// 0 … 1, the icon's beat as the ring leaves it.
        var beat: CGFloat

        /// 0 … 1: how lit a ring of `ringSize` is, which is how close the
        /// travelling ring is to it, and fading as the pulse spreads out.
        func light(at ringSize: CGFloat) -> CGFloat {
            guard opacity > 0 else { return 0 }
            let distance = (size - ringSize) / Metrics.Marquee.pulseReach
            let closeness = CGFloat(exp(-Double(distance * distance)))
            return closeness * CGFloat(opacity / Metrics.Marquee.pulseOpacity).squareRoot()
        }
    }

    private func currentPulse(at time: TimeInterval) -> Pulse? {
        guard !reduceMotion, let pulseStart, time >= pulseStart else { return nil }

        let period = Motion.Marquee.pulsePeriod
        let phase = (time - pulseStart).truncatingRemainder(dividingBy: period) / period

        let beatLength = Motion.Marquee.pulseBeatLength
        let beat = phase < beatLength ? CGFloat(sin(.pi * phase / beatLength)) : 0

        let travel = Motion.Marquee.pulseTravel
        guard phase < travel else {
            return Pulse(size: 0, opacity: 0, beat: beat)
        }

        // Quick off the icon, slowing as it spreads, and fading as it goes.
        let progress = phase / travel
        let eased = 1 - pow(1 - progress, 2)
        let size = Metrics.Marquee.iconSize
            + (Metrics.Marquee.pulseMaxSize - Metrics.Marquee.iconSize) * CGFloat(eased)
        let opacity = Metrics.Marquee.pulseOpacity * pow(1 - progress, 1.4)

        return Pulse(size: size, opacity: opacity, beat: beat)
    }

    private func schedulePulse() {
        guard appeared, pulseStart == nil else { return }
        pulseStart = Date.timeIntervalSinceReferenceDate + Motion.Marquee.pulseStartDelay
    }
}
