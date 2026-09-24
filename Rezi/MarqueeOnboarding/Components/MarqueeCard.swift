import SwiftUI

/// One card in a marquee row: the first screen's job card, scaled down.
///
/// Laid out at the full 353 × 76 and scaled as a whole, the way the first
/// screen shrinks the cards behind its front one, so the type, gauge and
/// shadow stay identical to it. Tapped, it rises out of the row under the
/// APPLY stamp.
struct MarqueeCard: View {
    var job: JobCard
    /// From the full-size card to this row's on-screen size.
    var scale: CGFloat
    var revealed: Bool
    var applied: Bool

    var body: some View {
        JobCardView(job: job, revealed: revealed)
            .overlay { ApplyStamp(strength: applied ? 1 : 0) }
            // The first screen's shadow: y 47.06, blur 50.88, #16192E at 5%.
            .shadow(
                color: Color(hex: 0x16192E).opacity(Metrics.cardShadowOpacity),
                radius: Metrics.cardShadowRadius,
                x: 0,
                y: Metrics.cardShadowY
            )
            .scaleEffect(scale, anchor: .topLeading)
            .frame(
                width: Metrics.cardWidth * scale,
                height: Metrics.cardHeight * scale,
                alignment: .topLeading
            )
            .scaleEffect(applied ? Metrics.Marquee.appliedLift : 1)
            .contentShape(
                RoundedRectangle(cornerRadius: Metrics.cardCornerRadius * scale, style: .continuous)
            )
    }
}

/// The first screen's APPLY stamp, for a tapped card: a green wash and border
/// across the card, and the badge in the middle.
struct ApplyStamp: View {
    /// 0 … 1.
    var strength: Double

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Metrics.cardCornerRadius, style: .continuous)

        ZStack {
            shape.fill(ReziColor.swipeApply.opacity(0.16 * strength))

            // Drawn before the card is scaled, so thickened to land at the
            // first screen's width on screen.
            shape
                .strokeBorder(
                    ReziColor.swipeApply,
                    lineWidth: Metrics.swipeBorderWidth / Metrics.Marquee.cardScale
                )
                .opacity(strength)

            badge
                .scaleEffect(Metrics.Marquee.appliedBadgeScale * (0.88 + 0.12 * strength))
                .opacity(strength)
        }
        .allowsHitTesting(false)
    }

    private var badge: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark")
                .font(.system(size: 13, weight: .heavy))
            Text("APPLY")
                .font(ReziFont.swipeStamp)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 15)
        .padding(.vertical, 9)
        .background(Capsule(style: .continuous).fill(ReziColor.swipeApply))
        .shadow(color: ReziColor.swipeApply.opacity(0.45), radius: 10, y: 4)
    }
}
