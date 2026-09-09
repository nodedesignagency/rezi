import Foundation
import SwiftUI

/// Drives the card deck.
///
/// A swipe never removes a card mid-flight. Instead the front card is thrown
/// off screen while `promoting` shifts every card behind it up one depth, and
/// only when both animations land does the deck actually rotate — silently,
/// into a layout identical to the one already on screen. That keeps the
/// promotion frame-perfect and lets the deck recycle forever.
///
/// Driven entirely from the main thread by SwiftUI, so it needs no isolation
/// of its own.
final class OnboardingModel: ObservableObject {

    @Published private(set) var deck: [JobCard]

    /// Live translation of the front card. Also used to fling it away.
    @Published var drag: CGSize = .zero
    @Published var isDragging = false

    /// While true, cards behind the front one render one depth shallower.
    @Published private(set) var promoting = false

    /// -1 … 1, how strongly to show the swipe's intent. Drives the badge.
    ///
    /// Deliberately its own value rather than being derived from `drag` in
    /// the view. Opacity is a rendered modifier, so a derived one would be
    /// animated on the fling's own curve and would not reach full strength
    /// until the card had already left. This is driven to full on its own
    /// short curve at the moment the swipe starts.
    @Published private(set) var swipeIntent: CGFloat = 0

    /// Bumped after every swipe so the autoplay timer restarts from zero.
    @Published private(set) var autoplayTick = 0

    /// Bumped only by swipes the user made, to drive haptics. Automatic
    /// cycling must not buzz the phone every few seconds.
    @Published private(set) var userSwipeCount = 0

    private var isSwiping = false

    init(deck: [JobCard] = JobCard.samples) {
        self.deck = deck
    }

    /// The cards kept in the view tree, front first.
    var visible: [JobCard] {
        Array(deck.prefix(Metrics.visibleCardCount))
    }

    /// Depth a card renders at, accounting for an in-flight promotion.
    /// The front card keeps depth 0 while it flies away.
    func renderDepth(for index: Int) -> Int {
        guard index > 0 else { return 0 }
        return promoting ? index - 1 : index
    }

    // MARK: - Dragging

    func beginDrag() {
        guard !isSwiping else { return }
        isDragging = true
    }

    func updateDrag(_ translation: CGSize) {
        guard !isSwiping else { return }
        drag = translation
        swipeIntent = intent(for: translation.width)
    }

    /// Ramps over a much shorter distance than the commit threshold, so the
    /// badge is readable long before a drag would actually commit.
    private func intent(for width: CGFloat) -> CGFloat {
        guard Metrics.swipeBadgeDistance > 0 else { return 0 }
        return max(-1, min(1, width / Metrics.swipeBadgeDistance))
    }

    /// Decides between committing and springing back.
    func endDrag(translation: CGSize, predictedEnd: CGSize, reduceMotion: Bool) {
        guard !isSwiping else { return }
        isDragging = false

        let travelled = abs(translation.width)
        let projected = abs(predictedEnd.width)
        let shouldCommit = travelled > Metrics.swipeCommitDistance
            || projected > Metrics.swipeCommitDistance * 2.2

        if shouldCommit {
            commit(
                translation.width >= 0 ? .right : .left,
                reduceMotion: reduceMotion,
                userInitiated: true
            )
        } else {
            withAnimation(Motion.settle) {
                drag = .zero
                swipeIntent = 0
            }
        }
    }

    // MARK: - Committing a swipe

    func commit(_ direction: SwipeDirection, reduceMotion: Bool, userInitiated: Bool = false) {
        guard !isSwiping, deck.count > 1 else { return }
        isSwiping = true
        isDragging = false
        if userInitiated { userSwipeCount += 1 }

        guard !reduceMotion else {
            // No fling to wait for, so rotate straight away — and clear the
            // drag, or the card promoted into the front inherits the offset
            // the last one was thrown to.
            withAnimation(Motion.entranceReduced) {
                rotateDeck()
                drag = .zero
                swipeIntent = 0
                promoting = false
            }
            isSwiping = false
            autoplayTick += 1
            return
        }

        flyAway(direction)
    }

    private func flyAway(_ direction: SwipeDirection) {
        // Its own, much shorter curve. Sharing the fling's would fade the
        // badge in over the entire departure.
        withAnimation(Motion.swipeIntentReveal) {
            swipeIntent = direction.sign
        }

        withAnimation(Motion.fling) {
            drag = CGSize(
                width: Metrics.swipeExitDistance * direction.sign,
                height: drag.height - 30
            )
        }
        withAnimation(Motion.promote) { promoting = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + Motion.flingSettleDelay) { [weak self] in
            self?.settleAfterFling()
        }
    }

    /// Rotates the deck without animating. The result is pixel-identical to
    /// what is already on screen, so nothing appears to move.
    private func settleAfterFling() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            rotateDeck()
            drag = .zero
            swipeIntent = 0
            promoting = false
        }
        isSwiping = false
        autoplayTick += 1
    }

    private func rotateDeck() {
        guard deck.count > 1 else { return }
        let front = deck.removeFirst()
        deck.append(front)
    }

    // MARK: - Derived state for the front card

    /// -1 … 1, how far the front card has been dragged toward a decision.
    var swipeProgress: CGFloat {
        guard Metrics.swipeCommitDistance > 0 else { return 0 }
        return max(-1, min(1, drag.width / Metrics.swipeCommitDistance))
    }

    var frontCardRotation: Double {
        Double(swipeProgress) * Metrics.swipeMaxRotation
    }
}
