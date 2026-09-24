import Foundation
import SwiftUI

/// Rectangle 65, the purple ribbon behind the rows, kept in motion.
///
/// Two things move it. The whole export sways and turns slowly about its own
/// centre, which changes where the purple lies on screen. And Figma's Warp
/// effect, a sine wave, runs live as a shader (`SineWarp.metal`), so the
/// ribbon's edges keep rippling instead of holding the single shape the export
/// froze.
///
/// The export is most of three screens wide, so it is cropped to the band the
/// ribbon can actually reach before the warp runs. The crop overhangs the
/// screen by the warp's amplitude on every side, so the edges it pulls inward
/// are always ones nobody can see.
///
/// Reduce Motion shows the export exactly as supplied, with nothing moving.
struct FlowingGradient: View {
    var appeared: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Motion is measured from here, so every sway starts from the Figma pose.
    @State private var startTime = Date.timeIntervalSinceReferenceDate

    private var hasArtwork: Bool { Artwork.has(Artwork.Name.marqueeGradient) }

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
        let hScale = size.width / Metrics.designWidth
        let vScale = size.height / Metrics.designHeight

        let art = CGSize(
            width: Metrics.Marquee.gradientSize.width * hScale,
            height: Metrics.Marquee.gradientSize.height * hScale
        )
        let origin = CGPoint(
            x: Metrics.Marquee.gradientOrigin.x * hScale,
            y: Metrics.Marquee.gradientOrigin.y * vScale
        )

        // Sway and turn. Sines from zero, so the first frame is the design.
        let swayX = Motion.Marquee.driftX * hScale * CGFloat(sin(elapsed * Motion.Marquee.driftSpeedX))
        let swayY = Motion.Marquee.driftY * hScale * CGFloat(sin(elapsed * Motion.Marquee.driftSpeedY))
        let turn = Motion.Marquee.driftAngle * sin(elapsed * Motion.Marquee.driftSpeedAngle)

        // The ripple wakes up rather than starting at full strength.
        let wake = min(1, elapsed / Motion.Marquee.warpWake)
        let amplitude = Motion.Marquee.warpAmplitude * hScale * CGFloat(wake)
        let margin = ceil(Motion.Marquee.warpAmplitude * hScale)

        // Only as deep as the ribbon can reach, drift included.
        let reach = min(
            size.height,
            origin.y + art.height + Metrics.Marquee.gradientOverreach * hScale
        )

        return artwork
            .frame(width: art.width, height: art.height)
            .mask { bottomFade }
            .rotationEffect(.degrees(turn))
            .offset(x: origin.x + margin + swayX, y: origin.y + margin + swayY)
            .frame(width: size.width + margin * 2, height: reach + margin * 2, alignment: .topLeading)
            .clipped()
            .distortionEffect(
                ShaderLibrary.sineWarp(
                    .float(Self.phase(elapsed, speed: Motion.Marquee.warpSpeedX)),
                    .float(Self.phase(elapsed, speed: Motion.Marquee.warpSpeedY)),
                    .float(amplitude),
                    .float(Motion.Marquee.warpWavelength * hScale)
                ),
                maxSampleOffset: CGSize(width: margin, height: margin),
                isEnabled: !reduceMotion
            )
            .offset(x: -margin, y: -margin)
            .frame(width: size.width, height: size.height, alignment: .topLeading)
    }

    /// Wrapped to one turn before it reaches the GPU, where it is a 32-bit
    /// float and would lose the precision a long-running clock needs.
    private static func phase(_ elapsed: Double, speed: Double) -> Double {
        (elapsed * speed).truncatingRemainder(dividingBy: 2 * .pi)
    }

    /// Dissolves the export's lower edge, which is otherwise a hard line
    /// wherever the drift lifts it into view.
    private var bottomFade: some View {
        LinearGradient(
            stops: [
                .init(color: .white, location: 0),
                .init(color: .white, location: 1 - Metrics.Marquee.gradientFade),
                .init(color: .clear, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Artwork

    @ViewBuilder
    private var artwork: some View {
        if hasArtwork {
            Image(Artwork.Name.marqueeGradient)
                .resizable()
        } else {
            drawnRibbon
        }
    }

    /// Stand-in when the export is missing: Rectangle 65's own radial stops,
    /// stretched into the diagonal ribbon the export shows, at the layer's 55%.
    private var drawnRibbon: some View {
        GeometryReader { geo in
            EllipticalGradient(
                stops: [
                    .init(color: ReziColor.Marquee.gradientCenter, location: 0),
                    .init(color: ReziColor.Marquee.gradientMid, location: 0.35),
                    .init(color: .white, location: 1)
                ],
                center: .center
            )
            .frame(width: geo.size.width * 1.3, height: geo.size.height * 0.62)
            .rotationEffect(.degrees(-29))
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .opacity(ReziColor.Marquee.gradientOpacity)
    }
}
