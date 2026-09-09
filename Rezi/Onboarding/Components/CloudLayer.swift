import SwiftUI

/// The cloud bank, drawn **in front of** the phone.
///
/// Figma stacks the clouds after the device, so the phone sinks into them
/// rather than sitting on top with a hard rectangular edge. That ordering is
/// the whole effect, so this is its own layer rather than part of the sky.
///
/// The band is placed at Figma's own geometry — five screens wide, hanging two
/// screens off the left edge. Only a fifth of it is on screen at a time, which
/// is why the design's clouds read as soft: what you see is a slice of one very
/// large puff, never a whole one at artwork scale.
struct CloudLayer: View {
    var appeared: Bool
    var size: CGSize

    private var hasCloudImage: Bool { Artwork.has(Artwork.Name.clouds) }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if hasCloudImage {
                // Behind: smaller and dimmer, so it sits further away.
                band(
                    scale: Metrics.cloudFarScale,
                    silhouetteY: Metrics.cloudFarSilhouetteY,
                    opacity: Metrics.cloudFarOpacity,
                    duration: Motion.cloudFarDuration
                )

                // Drawn several times over itself: the artwork peaks at 94%
                // alpha and ramps slowly, so one pass reads as a thin wisp.
                ForEach(0..<Metrics.cloudDensity, id: \.self) { _ in
                    band(
                        scale: 1,
                        silhouetteY: Metrics.cloudSilhouetteY,
                        opacity: 1,
                        duration: Motion.cloudNearDuration
                    )
                }
            } else {
                drawnClouds
            }
        }
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        // Dissolve the bank to nothing before it reaches the copy. The page
        // behind is white, so the cloud melts into it rather than leaving
        // texture under the headline, stats and button.
        .mask {
            LinearGradient(
                stops: [
                    .init(color: .white, location: 0),
                    .init(color: .white, location: Metrics.cloudFadeStart),
                    .init(color: .clear, location: Metrics.cloudFadeEnd),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .allowsHitTesting(false)
        .entrance(appeared, delay: Motion.Beat.clouds, offsetY: 0)
    }

    /// One copy of the band, positioned so its wisps land on `silhouetteY`
    /// rather than by its own top edge — the artwork's top quarter is empty,
    /// so placing it by the frame put the clouds far too high.
    private func band(
        scale: CGFloat,
        silhouetteY: CGFloat,
        opacity: Double,
        duration: Double
    ) -> some View {
        let width = size.width * Metrics.cloudBandWidthRatio * scale
        let height = width / Metrics.cloudBandAspect
        let left = size.width * Metrics.cloudBandLeftRatio * scale
        let top = Metrics.cloudBandTop(
            screenSize: size,
            bandHeight: height,
            silhouetteY: silhouetteY
        )

        return DriftingBand(
            imageName: Artwork.Name.clouds,
            width: width,
            height: height,
            travel: size.width * Metrics.cloudDriftTravel,
            duration: duration
        )
        .opacity(opacity)
        .offset(x: left, y: top)
    }

    /// Stand-in when no cloud artwork is present.
    private var drawnClouds: some View {
        ZStack(alignment: .top) {
            DriftingBlobClouds(band: .far, loopDuration: Motion.cloudFarDuration)
                .frame(width: size.width, height: size.height * 0.30)
                .opacity(Metrics.cloudFarOpacity)
                .offset(y: size.height * Metrics.cloudFarSilhouetteY)

            DriftingBlobClouds(band: .near, loopDuration: Motion.cloudNearDuration)
                .frame(width: size.width, height: size.height * 0.38)
                .offset(y: size.height * Metrics.cloudSilhouetteY)
        }
    }
}

/// Slides an image back and forth forever.
///
/// The band is far wider than the screen, so this never has to wrap and can
/// never show a seam — unlike tiling, where the artwork's two ends have to be
/// made to meet. Eased at both ends so the turn is not visible.
struct DriftingBand: View {
    var imageName: String
    var width: CGFloat
    var height: CGFloat
    var travel: CGFloat
    var duration: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = -1

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .offset(x: phase * travel)
            .onAppear {
                guard !reduceMotion, phase == -1 else { return }
                withAnimation(
                    .easeInOut(duration: duration).repeatForever(autoreverses: true)
                ) {
                    phase = 1
                }
            }
    }
}
