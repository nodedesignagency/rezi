import SwiftUI

/// The white page, the gradient sky, and the glow behind the phone.
///
/// Everything here sits *behind* the device. The clouds are a separate layer
/// drawn in front of it — see `CloudLayer`.
struct SkyBackground: View {
    var appeared: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathing = false

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

                glow(in: size)
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

    // MARK: - Glow

    /// Wide soft ellipse behind the base of the phone, breathing slowly so the
    /// sky is never completely still even where the gradient is subtle.
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
}
