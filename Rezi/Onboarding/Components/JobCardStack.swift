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

        JobCardView(
            job: job,
            revealed: appeared,
            isFront: isFront
        )
        .overlay {
            if isFront {
                swipeOverlay
            }
        }
        .shadow(
            color: Color(hex: 0x121A44).opacity(isFront ? 0.16 : 0.10),
            radius: isFront ? 18 : 10,
            x: 0,
            y: isFront ? 10 : 6
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

    /// A badge on the side you dragged away from, plus a matching edge tint —
    /// so the gesture reads as a decision, not just a shove.
    private var swipeOverlay: some View {
        let progress = model.swipeProgress
        let applyStrength = Double(max(0, progress))
        let passStrength = Double(max(0, -progress))
        let tint: Color = progress >= 0 ? ReziColor.swipeApply : ReziColor.swipePass

        return ZStack {
            RoundedRectangle(cornerRadius: Metrics.cardCornerRadius, style: .continuous)
                .strokeBorder(tint, lineWidth: 2)
                .opacity(max(applyStrength, passStrength) * 0.9)

            badge("APPLY", color: ReziColor.swipeApply)
                .opacity(applyStrength)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, Metrics.cardPaddingLeading)

            badge("PASS", color: ReziColor.swipePass)
                .opacity(passStrength)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, Metrics.cardPaddingTrailing)
        }
        .allowsHitTesting(false)
    }

    private func badge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(ReziFont.swipeStamp)
            .foregroundStyle(.white)
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(Capsule(style: .continuous).fill(color))
            .shadow(color: color.opacity(0.45), radius: 8, y: 3)
    }
}
