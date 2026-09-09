import SwiftUI

/// A solid white ellipse under a heavy blur, drawn over the phone and clouds.
///
/// This is Ellipse 7184 from the design: 578 x 250, filled white, layer blur
/// 50. It reads as nothing at all, which is the point — its whole job is to
/// dissolve the bottom of the device and the base of the sky into the white
/// page, so no hard device outline runs down behind the headline and stats.
///
/// It has to sit *above* the clouds. Underneath them the phone's edge still
/// shows through wherever the cloud happens to be thin.
///
/// The ellipse is paired with a plain white rectangle below it, because an
/// ellipse narrows towards its ends and stops covering the phone exactly
/// where the copy sits.
struct WhiteVeil: View {
    var appeared: Bool
    var size: CGSize

    var body: some View {
        let hScale = size.width / Metrics.designWidth
        let vScale = size.height / Metrics.designHeight
        let centerY = size.height * Metrics.veilCenterYRatio

        ZStack(alignment: .top) {
            // Solid white from the ellipse's waist down.
            //
            // The ellipse alone is not enough: it tapers, so below about 570pt
            // it is narrower than the phone and stops reaching the device's
            // edges — which is precisely where the headline, subtitle and
            // stats sit, and why the outline was still showing through them.
            // Its widest point is full-bleed, so this rectangle's top edge
            // hides underneath it and leaves no seam.
            Rectangle()
                .fill(Color.white)
                .frame(width: size.width, height: max(0, size.height - centerY))
                .offset(y: centerY)

            // The soft top edge of the transition, straight from the design:
            // a solid white ellipse under a heavy blur.
            Ellipse()
                .fill(Color.white)
                .frame(
                    width: Metrics.veilWidth * hScale,
                    height: Metrics.veilHeight * vScale
                )
                .blur(radius: Metrics.veilBlur * hScale)
                .offset(y: centerY - Metrics.veilHeight * vScale / 2)
        }
        .frame(width: size.width, height: size.height, alignment: .top)
        .allowsHitTesting(false)
        .entrance(appeared, delay: Motion.Beat.clouds, offsetY: 0)
    }
}
