import SwiftUI

/// The white page and the gradient sky.
///
/// Both sit *behind* the device. The clouds, and the white veil that dissolves
/// the phone into the page, are separate layers drawn in front of it — see
/// `CloudLayer` and `WhiteVeil`.
struct SkyBackground: View {
    var appeared: Bool

    private var hasBackgroundImage: Bool { Artwork.has(Artwork.Name.background) }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let skyHeight = size.height * Metrics.skyHeightRatio

            ZStack(alignment: .top) {
                ReziColor.page

                sky
                    .frame(width: size.width, height: skyHeight)
                    .mask {
                        // Melts into the page instead of ending on a hard line.
                        LinearGradient(
                            stops: [
                                .init(color: .white, location: 0),
                                .init(color: .white, location: Metrics.skyFadeStart),
                                .init(color: .clear, location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    .entrance(appeared, delay: Motion.Beat.sky, offsetY: 0, startScale: 1.05)

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
            AnimatedSky()
        }
    }

}
