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
                    topRatio: Metrics.cloudFarTopRatio,
                    opacity: Metrics.cloudFarOpacity,
                    duration: Motion.cloudFarDuration
                )

                band(
                    scale: 1,
                    topRatio: Metrics.cloudBandTopRatio,
                    opacity: 1,
                    duration: Motion.cloudNearDuration
                )
            } else {
                drawnClouds
            }
        }
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .allowsHitTesting(false)
        .entrance(appeared, delay: Motion.Beat.clouds, offsetY: 0)
    }

    /// One copy of the band, positioned by ratio off the artboard.
    private func band(
        scale: CGFloat,
        topRatio: CGFloat,
        opacity: Double,
        duration: Double
    ) -> some View {
        let width = size.width * Metrics.cloudBandWidthRatio * scale
        let height = width / Metrics.cloudBandAspect
        let left = size.width * Metrics.cloudBandLeftRatio * scale

        return DriftingBand(
            imageName: Artwork.Name.clouds,
            width: width,
            height: height,
            travel: size.width * Metrics.cloudDriftTravel,
            duration: duration
        )
        .opacity(opacity)
        .offset(x: left, y: size.height * topRatio)
    }

    /// Stand-in when no cloud artwork is present.
    private var drawnClouds: some View {
        ZStack(alignment: .top) {
            DriftingBlobClouds(band: .far, loopDuration: Motion.cloudFarDuration)
                .frame(width: size.width, height: size.height * 0.30)
                .opacity(Metrics.cloudFarOpacity)
                .offset(y: size.height * 0.34)

            DriftingBlobClouds(band: .near, loopDuration: Motion.cloudNearDuration)
                .frame(width: size.width, height: size.height * 0.38)
                .offset(y: size.height * 0.40)
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
