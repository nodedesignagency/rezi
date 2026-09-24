import SwiftUI

/// One row of the feed: five cards on a loop, cruising one way, that can be
/// grabbed, thrown, and tapped to apply.
///
/// Each card wraps on its own. When one leaves an edge it reappears past the
/// other, out of sight, because the loop is always wider than the screen plus
/// a card. So there is no seam, and never more than five cards in the tree.
///
/// Motion comes from `MarqueeTrack`, read once a frame. Gestures only ever hand
/// it a new starting point, which is what keeps a drag, a fling and the cruise
/// continuous with one another.
struct MarqueeRow: View {
    var cards: [JobCard]
    var direction: SwipeDirection
    /// Cruising speed, in on-screen points per second.
    var speed: CGFloat
    /// Leading edge of the first card before anything has moved.
    var phase: CGFloat
    /// From the first screen's full-size card to this row's.
    var cardScale: CGFloat
    var gap: CGFloat
    var width: CGFloat
    var appeared: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var track = MarqueeTrack()
    /// Where the row would sit at zero translation, for the drag in progress.
    @State private var grabOrigin: CGFloat?
    @GestureState private var isTouching = false

    @State private var appliedID: UUID?
    /// Bumped on every tap: drives the haptic, and tells a pending un-stamp
    /// whether a newer tap has superseded it.
    @State private var tapCount = 0

    private var cardWidth: CGFloat { Metrics.cardWidth * cardScale }
    private var cardHeight: CGFloat { Metrics.cardHeight * cardScale }
    private var pitch: CGFloat { cardWidth + gap }
    private var loopLength: CGFloat { pitch * CGFloat(cards.count) }

    var body: some View {
        TimelineView(.animation) { context in
            let offset = phase + track.position(at: context.date.timeIntervalSinceReferenceDate)

            ZStack(alignment: .topLeading) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { entry in
                    card(entry.element, index: entry.offset, offset: offset)
                }
            }
        }
        .frame(width: width, height: cardHeight, alignment: .topLeading)
        // The gaps between cards grab the row too.
        .contentShape(Rectangle())
        .gesture(drag)
        .onAppear(perform: startCruising)
        .onChange(of: appeared) { startCruising() }
        .onChange(of: reduceMotion) { startCruising() }
        .onChange(of: isTouching) { _, touching in
            if !touching { releaseIfStillHeld() }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: tapCount)
        // Decorative: a VoiceOver cursor cannot follow cards that keep moving.
        .accessibilityHidden(true)
    }

    // MARK: - One card

    private func card(_ job: JobCard, index: Int, offset: CGFloat) -> some View {
        // Distance along the loop, which lap of it this is, and where that
        // puts the card on screen: somewhere in -pitch ..< loop - pitch.
        let travelled = offset + CGFloat(index) * pitch + pitch
        let lap = (travelled / loopLength).rounded(.down)
        let x = travelled - lap * loopLength - pitch

        let gaugeX = x + cardWidth * Metrics.Marquee.gaugeCenterRatio
        let gaugeOnScreen = gaugeX > 0 && gaugeX < width
        let isApplied = appliedID == job.id

        return MarqueeCard(
            job: job,
            scale: cardScale,
            revealed: appeared && gaugeOnScreen,
            applied: isApplied
        )
        // A fresh card each lap, created off screen with an empty gauge, so it
        // scores itself again as it comes back round.
        .id(Int(lap))
        .onTapGesture { apply(job) }
        .zIndex(isApplied ? 1 : 0)
        .offset(x: x)
    }

    // MARK: - Cruising

    private func startCruising() {
        guard appeared else { return }
        let cruise = reduceMotion ? 0 : speed * direction.sign
        track.setCruise(cruise, at: Date.timeIntervalSinceReferenceDate)
    }

    // MARK: - Drag

    private var drag: some Gesture {
        DragGesture(minimumDistance: 6)
            .updating($isTouching) { _, touching, _ in
                touching = true
            }
            .onChanged { value in
                if grabOrigin == nil {
                    let now = Date.timeIntervalSinceReferenceDate
                    // Measured back from the current translation, so the row
                    // does not jump by the gesture's minimum distance.
                    grabOrigin = track.position(at: now) - value.translation.width
                }
                track.hold(at: (grabOrigin ?? 0) + value.translation.width)
            }
            .onEnded { value in
                let now = Date.timeIntervalSinceReferenceDate
                let position = grabOrigin.map { $0 + value.translation.width }
                    ?? track.position(at: now)
                let limit = Motion.Marquee.rowMaxFling
                let fling = min(max(value.velocity.width, -limit), limit)

                track.release(at: position, velocity: fling, time: now)
                grabOrigin = nil
            }
    }

    /// A drag the system cancels never reaches `onEnded`. Without this, the
    /// row would stay pinned wherever the finger was.
    private func releaseIfStillHeld() {
        guard track.isHeld else { return }
        let now = Date.timeIntervalSinceReferenceDate
        track.release(at: track.position(at: now), velocity: 0, time: now)
        grabOrigin = nil
    }

    // MARK: - Tap to apply

    private func apply(_ job: JobCard) {
        let now = Date.timeIntervalSinceReferenceDate
        // Catch the row so the stamped card holds still to be read. It picks
        // back up on its own, on the same curve as after a fling.
        track.release(at: track.position(at: now), velocity: 0, time: now)

        tapCount += 1
        let tap = tapCount
        withAnimation(Motion.Marquee.applyIn) {
            appliedID = job.id
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Motion.Marquee.applyHold) {
            guard tapCount == tap else { return }
            withAnimation(Motion.Marquee.applyOut) {
                appliedID = nil
            }
        }
    }
}
