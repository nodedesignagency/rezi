import SwiftUI

/// The cloud bank, drawn **in front of** the phone.
///
/// Figma stacks the clouds after the device, so the phone sinks into them
/// rather than sitting on top with a hard rectangular edge. That ordering is
/// the whole effect, so this is deliberately its own layer rather than part of
/// `SkyBackground`.
struct CloudLayer: View {
    var appeared: Bool
    var size: CGSize

    private var hasCloudImage: Bool { Artwork.has(Artwork.Name.clouds) }

    var body: some View {
        ZStack(alignment: .top) {
            // Distant haze. Always drawn shapes — a photograph scaled this
            // small would read as detail, and haze should have no edges.
            DriftingBlobClouds(band: .far, loopDuration: Motion.cloudFarDuration)
                .frame(width: size.width, height: size.height * Metrics.cloudFarHeightRatio)
                .opacity(Metrics.cloudFarOpacity)
                .offset(y: size.height * Metrics.cloudFarTopRatio)

            nearBank
        }
        .frame(width: size.width, height: size.height, alignment: .top)
        .allowsHitTesting(false)
        .entrance(appeared, delay: Motion.Beat.clouds, offsetY: 0)
    }

    /// The real cloud artwork, scaled well past the screen so its puffs read
    /// large, and softened so the photographic grain settles into the design.
    @ViewBuilder
    private var nearBank: some View {
        let layout = Metrics.cloudNearLayout(screenSize: size)

        // Clipped to what is actually on screen *before* blurring. The bank is
        // over twice the screen wide and taller than the screen; blurring it
        // whole would put a multi-thousand-point layer through the filter on
        // every frame of the drift.
        let bleed = Metrics.cloudBlurBleed
        let visibleHeight = max(0, size.height - layout.top)

        Group {
            if hasCloudImage {
                DriftingImageClouds(
                    imageName: Artwork.Name.clouds,
                    tileWidth: layout.size.width,
                    tileHeight: layout.size.height,
                    loopDuration: Motion.cloudNearDuration
                )
            } else {
                DriftingBlobClouds(band: .near, loopDuration: Motion.cloudNearDuration)
                    .frame(width: size.width, height: layout.size.height * 0.5)
            }
        }
        .frame(width: size.width + bleed * 2, height: visibleHeight, alignment: .topLeading)
        .clipped()
        .blur(radius: Metrics.cloudNearBlur)
        .offset(x: -bleed, y: layout.top)
    }
}
