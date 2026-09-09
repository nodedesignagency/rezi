import SwiftUI

/// The blue → purple sky, the glow behind the phone, and the drifting clouds.
///
/// If `OnboardingBackground` is in the asset catalog it is used as-is;
/// otherwise the gradient is drawn. The cloud bank is a separate drifting
/// layer either way, so it keeps moving over a supplied background.
struct SkyBackground: View {
    var appeared: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathing = false

    private var hasBackgroundImage: Bool { Artwork.has(Artwork.Name.background) }
    private var hasCloudImage: Bool { Artwork.has(Artwork.Name.clouds) }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let skyHeight = size.height * Metrics.skyHeightRatio

            ZStack(alignment: .top) {
                ReziColor.page

                sky
                    .frame(width: size.width, height: skyHeight)
                    .clipped()
                    .entrance(appeared, delay: Motion.Beat.sky, offsetY: 0, startScale: 1.05)

                glow(in: size)

                clouds(in: size)
            }
            .frame(width: size.width, height: size.height, alignment: .top)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    // MARK: - Sky

    @ViewBuilder
    private var sky: some View {
        if hasBackgroundImage {
            Image(Artwork.Name.background)
                .resizable()
                .scaledToFill()
        } else {
            ProceduralSky()
        }
    }

    // MARK: - Glow

    /// Wide soft ellipse sitting behind the base of the phone, breathing
    /// slowly so the sky never looks completely still.
    private func glow(in size: CGSize) -> some View {
        let vScale = size.height / Metrics.designHeight
        let hScale = size.width / Metrics.designWidth

        return Ellipse()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.85),
                        Color.white.opacity(0.35),
                        Color.white.opacity(0)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: Metrics.glowWidth * hScale * 0.5
                )
            )
            .frame(
                width: Metrics.glowWidth * hScale,
                height: Metrics.glowHeight * vScale
            )
            .blur(radius: 26)
            .scaleEffect(breathing ? 1.06 : 0.95)
            .position(x: size.width / 2, y: Metrics.glowCenterY * vScale)
            .entrance(appeared, delay: Motion.Beat.glow, offsetY: 0)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(Motion.glowBreath) { breathing = true }
            }
    }

    // MARK: - Clouds

    /// Two layers at different depths. The far one is soft drawn haze that
    /// never resolves into a hard edge; the near one is the real cloud bank,
    /// whose opaque lower half is what dissolves the sky into the white page.
    private func clouds(in size: CGSize) -> some View {
        ZStack(alignment: .top) {
            DriftingBlobClouds(band: .far, loopDuration: Motion.cloudFarDuration)
                .frame(width: size.width, height: size.height * Metrics.cloudFarHeightRatio)
                .opacity(Metrics.cloudFarOpacity)
                .offset(y: size.height * Metrics.cloudFarTopRatio)

            nearClouds(in: size)
        }
        .entrance(appeared, delay: Motion.Beat.sky, offsetY: 0)
    }

    @ViewBuilder
    private func nearClouds(in size: CGSize) -> some View {
        let tileHeight = size.height * Metrics.cloudNearHeightRatio
        let tileWidth = tileHeight * Metrics.cloudAspect
        let top = Metrics.cloudNearTop(screenHeight: size.height)

        Group {
            if hasCloudImage {
                DriftingImageClouds(
                    imageName: Artwork.Name.clouds,
                    tileWidth: tileWidth,
                    tileHeight: tileHeight,
                    loopDuration: Motion.cloudNearDuration
                )
            } else {
                DriftingBlobClouds(band: .near, loopDuration: Motion.cloudNearDuration)
                    .frame(width: size.width, height: tileHeight * 0.5)
            }
        }
        .frame(width: size.width, height: tileHeight, alignment: .topLeading)
        .clipped()
        .offset(y: top)
    }
}

/// The gradient stand-in for `OnboardingBackground`, fading out at the bottom
/// so it melts into the white page rather than ending on a hard edge.
struct ProceduralSky: View {
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: ReziColor.skyDeep, location: 0.00),
                .init(color: ReziColor.skyBlue, location: 0.30),
                .init(color: ReziColor.skyIndigo, location: 0.64),
                .init(color: ReziColor.skyPurple, location: 1.00)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            // Cooler, brighter wash across the top edge, as in the design.
            RadialGradient(
                colors: [Color(hex: 0x3A6BF0).opacity(0.55), .clear],
                center: UnitPoint(x: 0.72, y: -0.05),
                startRadius: 0,
                endRadius: 420
            )
        }
        .mask {
            LinearGradient(
                stops: [
                    .init(color: .white, location: 0.00),
                    .init(color: .white, location: 0.52),
                    .init(color: .clear, location: 0.80)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
