import Foundation
import SwiftUI

/// Rectangle 65, the purple ribbon behind the rows, drawn in code and kept in
/// motion.
///
/// It is the design's own fill, a long thin elliptical gradient from a pale
/// violet core through vivid purple to white, on a layer at 55%, given
/// Figma's sine-wave Warp by a shader (`SineWarp.metal`). Nothing here is an
/// image, so the shape itself moves rather than a picture of it sliding about:
/// the ellipse wanders, turns, stretches and swells, its core grows and
/// shrinks, the S-bend travels along it, and a finer ripple plays over the top.
///
/// Only the band the ribbon can reach is drawn, and the warp runs over just
/// that. It overhangs the screen by the warp's reach on every side, so any edge
/// the shader pulls inward is one nobody can see.
///
/// Reduce Motion holds the Figma pose.
struct FlowingGradient: View {
    var appeared: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Motion is measured from here, so everything starts from the Figma pose.
    @State private var startTime = Date.timeIntervalSinceReferenceDate

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: nil, paused: reduceMotion)) { context in
                let elapsed = reduceMotion
                    ? 0
                    : max(0, context.date.timeIntervalSinceReferenceDate - startTime)

                ribbon(in: geo.size, elapsed: elapsed)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .entrance(appeared, delay: Motion.Marquee.Beat.gradient, offsetY: 0, startScale: 1.04)
    }

    // MARK: - Ribbon

    private func ribbon(in size: CGSize, elapsed: Double) -> some View {
        let scale = size.width / Metrics.designWidth

        /// A sine of the clock at `speed`, starting from zero.
        func sway(_ speed: Double) -> CGFloat {
            CGFloat(sin(elapsed * speed))
        }

        // The ellipse, in its pose for this frame.
        let center = CGPoint(
            x: (Metrics.Marquee.ribbonCenter.x + Motion.Marquee.driftX * sway(Motion.Marquee.driftSpeedX)) * scale,
            y: (Metrics.Marquee.ribbonCenter.y + Motion.Marquee.driftY * sway(Motion.Marquee.driftSpeedY)) * scale
        )
        let angle = Metrics.Marquee.ribbonAngle
            + Motion.Marquee.driftAngle * Double(sway(Motion.Marquee.driftSpeedAngle))
        let length = Metrics.Marquee.ribbonRadii.width * scale
            * (1 + Motion.Marquee.stretch * sway(Motion.Marquee.stretchSpeed))
        let thickness = Metrics.Marquee.ribbonRadii.height * scale
            * (1 + Motion.Marquee.swell * sway(Motion.Marquee.swellSpeed))
        let core = Metrics.Marquee.ribbonCoreStop
            + Motion.Marquee.coreShift * sway(Motion.Marquee.coreSpeed)

        // The warp. Everything the shader reads is in the canvas, which starts
        // `margin` above and to the left of the screen, so the bend's phase is
        // moved back by that much to keep the S where the design has it.
        let margin = ceil((Metrics.Marquee.ribbonBend + Motion.Marquee.rippleAmplitude) * scale)
        let bend = Metrics.Marquee.ribbonBend * scale
        let bendWaveNumber = 2 * .pi / (Metrics.Marquee.ribbonBendWavelength * scale)
        let bendPhase = Metrics.Marquee.ribbonBendPhase
            - Double(bendWaveNumber * margin)
            + elapsed * Motion.Marquee.bendSpeed
        let wake = min(1, elapsed / Motion.Marquee.rippleWake)
        let ripple = Motion.Marquee.rippleAmplitude * scale * CGFloat(wake)
        let rippleWaveNumber = 2 * .pi / (Motion.Marquee.rippleWavelength * scale)

        let reach = min(size.height, Metrics.Marquee.ribbonReach * scale)

        return EllipticalGradient(
            stops: [
                .init(color: ReziColor.Marquee.ribbonCore, location: 0),
                .init(color: ReziColor.Marquee.ribbonBand, location: core),
                .init(color: .white, location: 1)
            ],
            center: .center,
            startRadiusFraction: 0,
            endRadiusFraction: 0.5
        )
        .frame(width: length * 2, height: thickness * 2)
        .rotationEffect(.degrees(angle))
        .position(x: center.x + margin, y: center.y + margin)
        .frame(width: size.width + margin * 2, height: reach + margin * 2)
        .opacity(ReziColor.Marquee.ribbonOpacity)
        .mask { bottomFade }
        .clipped()
        .distortionEffect(
            ShaderLibrary.sineWarp(
                .float(bend),
                .float(bendWaveNumber),
                .float(Self.wrapped(bendPhase)),
                .float(ripple),
                .float(rippleWaveNumber),
                .float(Self.wrapped(elapsed * Motion.Marquee.rippleSpeedX)),
                .float(Self.wrapped(elapsed * Motion.Marquee.rippleSpeedY))
            ),
            maxSampleOffset: CGSize(width: margin, height: margin)
        )
        .offset(x: -margin, y: -margin)
        .frame(width: size.width, height: size.height, alignment: .topLeading)
    }

    /// Wrapped to one turn before it reaches the GPU, where it is a 32-bit
    /// float and would lose the precision a long-running clock needs.
    private static func wrapped(_ phase: Double) -> Double {
        phase.truncatingRemainder(dividingBy: 2 * .pi)
    }

    /// Dissolves the bottom of the band, in case the ribbon has not quite
    /// faded to white by then.
    private var bottomFade: some View {
        LinearGradient(
            stops: [
                .init(color: .white, location: 0),
                .init(color: .white, location: 1 - Metrics.Marquee.ribbonFade),
                .init(color: .clear, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
