import SwiftUI

/// The deck of job cards — the part of the screen that demonstrates the
/// product. It deals itself in, cycles on its own, and can be thrown by hand.
struct JobCardStack: View {
    @ObservedObject var model: OnboardingModel
    var appeared: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Tall enough to hold the front card plus the two peeking out below it.
    private var stackHeight: CGFloat {
        Metrics.cardOffsetY(depth: 2) + Metrics.cardHeight * Metrics.cardScale(depth: 2)
    }

    var body: some View {
        ZStack(alignment: .top) {
            ForEach(Array(model.visible.enumerated()), id: \.element.id) { entry in
                cardView(job: entry.element, index: entry.offset)
            }
        }
        .frame(width: Metrics.cardWidth, height: stackHeight, alignment: .top)
        .accessibilityElement(children: .contain)
        .accessibilityAction(named: "Apply to this job") {
            model.commit(.right, reduceMotion: reduceMotion, userInitiated: true)
        }
        .accessibilityAction(named: "Skip this job") {
            model.commit(.left, reduceMotion: reduceMotion, userInitiated: true)
        }
    }

    // MARK: - One card

    @ViewBuilder
    private func cardView(job: JobCard, index: Int) -> some View {
        let depth = model.renderDepth(for: index)
        let isFront = index == 0
        let isSpare = depth >= Metrics.hiddenCardDepth

        JobCardView(job: job, revealed: appeared)
        .overlay {
            if isFront {
                swipeOverlay
            }
        }
        // Figma: y 47.06, blur 50.88, #16192E at 5% — a wide, soft shadow
        // thrown well below the card rather than a tight one under it.
        .shadow(
            color: Color(hex: 0x16192E).opacity(Metrics.cardShadowOpacity),
            radius: Metrics.cardShadowRadius,
            x: 0,
            y: Metrics.cardShadowY
        )
        .scaleEffect(Metrics.cardScale(depth: depth), anchor: .top)
        .rotationEffect(.degrees(isFront ? model.frontCardRotation : 0))
        .offset(y: Metrics.cardOffsetY(depth: depth))
        .offset(isFront ? model.drag : .zero)
        .opacity(isSpare ? 0 : 1)
        .zIndex(Double(Metrics.visibleCardCount - index))
        .entrance(
            appeared,
            delay: Motion.Beat.cards + Double(index) * Motion.Beat.cardStagger,
            offsetY: 44,
            startScale: 0.88
        )
        // Attached to every card but live only on the front one:
        // `.gesture(cond ? g : nil)` has no valid type, a mask does.
        .gesture(dragGesture, including: isFront ? .all : .none)
    }

    // MARK: - Drag

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                if !model.isDragging { model.beginDrag() }
                withAnimation(Motion.track) {
                    model.updateDrag(value.translation)
                }
            }
            .onEnded { value in
                model.endDrag(
                    translation: value.translation,
                    predictedEnd: value.predictedEndTranslation,
                    reduceMotion: reduceMotion
                )
            }
    }

    // MARK: - Drag affordances

    /// Says what the swipe will do, plainly enough to read while it happens.
    ///
    /// This used to be a small pill pinned to the leading edge — which is
    /// exactly where the company logo sits, so it was half-covered — and it
    /// only existed for the length of the fling. Centred, with an icon and a
    /// wash across the whole card, there is something to see; ramping it over
    /// `swipeBadgeDistance` rather than the commit distance brings it up
    /// early enough in the travel to read.
    private var swipeOverlay: some View {
        let progress = model.swipeSignal
        let applying = Double(max(0, progress))
        let passing = Double(max(0, -progress))
        let strength = max(applying, passing)
        let tint: Color = progress >= 0 ? ReziColor.swipeApply : ReziColor.swipePass
        let shape = RoundedRectangle(
            cornerRadius: Metrics.cardCornerRadius,
            style: .continuous
        )

        return ZStack {
            shape.fill(tint.opacity(0.16 * strength))
            shape.strokeBorder(tint, lineWidth: 2).opacity(strength)

            badge("APPLY", symbol: "checkmark", color: ReziColor.swipeApply)
                .opacity(applying)
                .scaleEffect(0.88 + 0.12 * applying)

            badge("PASS", symbol: "xmark", color: ReziColor.swipePass)
                .opacity(passing)
                .scaleEffect(0.88 + 0.12 * passing)
        }
        .allowsHitTesting(false)
    }

    private func badge(_ text: String, symbol: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .heavy))
            Text(text)
                .font(ReziFont.swipeStamp)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 15)
        .padding(.vertical, 9)
        .background(Capsule(style: .continuous).fill(color))
        .shadow(color: color.opacity(0.45), radius: 10, y: 4)
    }
}
