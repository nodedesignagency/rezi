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
struct WhiteVeil: View {
    var appeared: Bool
    var size: CGSize

    var body: some View {
        let hScale = size.width / Metrics.designWidth
        let vScale = size.height / Metrics.designHeight

        Ellipse()
            .fill(Color.white)
            .frame(
                width: Metrics.veilWidth * hScale,
                height: Metrics.veilHeight * vScale
            )
            .blur(radius: Metrics.veilBlur * hScale)
            .position(
                x: size.width * Metrics.veilCenterXRatio,
                y: size.height * Metrics.veilCenterYRatio
            )
            .allowsHitTesting(false)
            .entrance(appeared, delay: Motion.Beat.clouds, offsetY: 0)
    }
}
