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
/// It arrives the same way it moves, from its own values each frame: fading
/// in and filling out to its full thickness. Never with a view animation. A
/// scale or offset animating on the layer that holds the shader makes iOS
/// draw the shader over the wrong region until it settles, which showed as a
/// hard edge across the ribbon and a bite out of its top on launch.
///
/// Reduce Motion holds the Figma pose, and fades it in.
struct FlowingGradient: View {
    var appeared: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Motion is measured from here, so everything starts from the Figma pose.
    @State private var startTime = Date.timeIntervalSinceReferenceDate
    /// When the ribbon begins to arrive, once the screen has appeared.
    @State private var arrivalStart: TimeInterval?

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: nil, paused: reduceMotion)) { context in
                let now = context.date.timeIntervalSinceReferenceDate
                let elapsed = reduceMotion ? 0 : max(0, now - startTime)
                let arrival = reduceMotion ? 1 : arrivalProgress(at: now)

                ribbon(in: geo.size, elapsed: elapsed, arrival: arrival)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        // Reduce Motion's plain cross-fade. Otherwise always visible here: the
        // arrival is drawn inside the ribbon instead, for the reason above.
        .entrance(appeared || !reduceMotion, delay: Motion.Marquee.Beat.gradient, offsetY: 0)
        .onAppear(perform: beginArrival)
        .onChange(of: appeared) { beginArrival() }
    }

    // MARK: - Arrival

    private func beginArrival() {
        guard appeared, arrivalStart == nil else { return }
        arrivalStart = Date.timeIntervalSinceReferenceDate + Motion.Marquee.Beat.gradient
    }

    /// 0 before the screen has appeared, easing out to 1.
    private func arrivalProgress(at time: TimeInterval) -> CGFloat {
        guard let arrivalStart else { return 0 }
        let progress = min(1, max(0, (time - arrivalStart) / Motion.Marquee.ribbonArrival))
        return CGFloat(1 - pow(1 - progress, 3))
    }

    // MARK: - Ribbon

    /// - Parameter arrival: 0 … 1, how far the ribbon has arrived.
    private func ribbon(in size: CGSize, elapsed: Double, arrival: CGFloat) -> some View {
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
        let bloom = 1 - Motion.Marquee.ribbonArrivalBloom * (1 - arrival)
        let thickness = Metrics.Marquee.ribbonRadii.height * scale
            * (1 + Motion.Marquee.swell * sway(Motion.Marquee.swellSpeed))
            * bloom
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
        .opacity(ReziColor.Marquee.ribbonOpacity * Double(arrival))
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
