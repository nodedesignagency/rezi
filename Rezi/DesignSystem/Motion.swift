import SwiftUI

/// Timing for the whole screen, in one place.
///
/// Everything here has a Reduce Motion counterpart. With the accessibility
/// setting on, elements cross-fade into their final state instead of
/// travelling, and the ambient loops stop entirely.
enum Motion {

    // MARK: - Entrance

    /// The spring each element rides in on.
    static let entranceSpring = Animation.spring(response: 0.62, dampingFraction: 0.78)
    /// Looser and bouncier, for the app icon's arrival.
    static let appIconSpring = Animation.spring(response: 0.55, dampingFraction: 0.58)
    /// Cross-fade used instead when Reduce Motion is on.
    static let entranceReduced = Animation.easeOut(duration: 0.35)

    /// When each element starts, in seconds after the screen appears.
    enum Beat {
        static let sky: Double = 0.00
        static let clouds: Double = 0.08
        static let phone: Double = 0.10
        static let cards: Double = 0.24
        /// Added per card, so the stack deals itself out.
        static let cardStagger: Double = 0.09
        static let appIcon: Double = 0.56
        static let headline: Double = 0.68
        static let subhead: Double = 0.78
        static let stats: Double = 0.88
        /// Added per stat column.
        static let statStagger: Double = 0.07
        static let button: Double = 1.02
        static let signIn: Double = 1.12
    }

    /// Held before flipping `appeared`, so the pre-animation state renders
    /// for one frame first. Without it the springs have nothing to travel from.
    static let entranceLeadIn: Duration = .milliseconds(80)

    // MARK: - Card stack

    /// A card leaving.
    ///
    /// One continuous curve, deliberately not a symmetric ease. It opens at a
    /// real speed so the card never looks like it hesitated, cruises through
    /// the part of the travel that is actually on screen, then accelerates
    /// away. That shape is what buys the badge its reading time: about eight
    /// tenths of a second legible with the card still visible, against under
    /// two tenths on a plain ease-in-out.
    ///
    /// An earlier version held the card still mid-swipe to achieve the same
    /// thing. It read as a freeze. The time has to come out of the curve.
    static let fling = Animation.timingCurve(0.22, 0.06, 0.72, 0.42, duration: 1.20)
    /// Just past `fling`, so the deck rotates once the card has landed.
    static let flingSettleDelay: TimeInterval = 1.24

    /// The stack closing up behind it. Shorter than the fling on purpose —
    /// the gap settles while the card is still on its way out, rather than
    /// the whole screen waiting for it.
    static let promote = Animation.easeInOut(duration: 0.75)

    /// Following the finger.
    static let track = Animation.interactiveSpring(response: 0.24, dampingFraction: 0.9)
    /// Letting go without committing. Damped hard, so it glides back instead
    /// of bouncing.
    static let settle = Animation.easeInOut(duration: 0.42)

    /// Gap between automatic swipes. Long enough that a card is fully at rest
    /// before the next one goes, so the deck reads as one card at a time
    /// rather than a queue being flushed.
    static let autoplayInterval: Duration = .seconds(3.8)
    /// Longer first gap, so the entrance finishes before the deck starts moving.
    static let autoplayFirstInterval: Duration = .seconds(4.0)

    // MARK: - Gauge

    static let gaugeSweep = Animation.easeOut(duration: 0.75)
    /// Held long enough that the arc fills as the card lands, not while
    /// it is still flying in.
    static let gaugeSweepDelay: Double = 0.28

    // MARK: - Ambient

    /// Seconds for one sweep of each cloud layer.
    ///
    /// The band slides back and forth rather than looping, which it can do
    /// without ever showing a seam because it is five screens wide. Eased at
    /// both ends so the turn is invisible; the two layers use different
    /// periods so they drift in and out of phase instead of moving as one.
    static let cloudNearDuration: Double = 110
    static let cloudFarDuration: Double = 170

    static let glowBreath = Animation.easeInOut(duration: 5).repeatForever(autoreverses: true)
    static let buttonShineDuration: Double = 3.4

    // MARK: - Button

    static let buttonPress = Animation.spring(response: 0.26, dampingFraction: 0.62)

    // MARK: - Helpers

    /// The entrance spring, or a plain fade when Reduce Motion is on.
    ///
    /// Reduce Motion also compresses the stagger, so the screen settles
    /// promptly instead of fading in over a second and a half.
    static func entranceAnimation(
        delay: Double,
        reduceMotion: Bool,
        override: Animation? = nil
    ) -> Animation {
        reduceMotion
            ? entranceReduced.delay(min(delay, 0.2))
            : (override ?? entranceSpring).delay(delay)
    }
}

// MARK: - Entrance modifier

/// Fades, lifts and scales a view in from its off state.
///
/// With Reduce Motion on, the travel and scale are dropped and only the
/// opacity change survives.
struct EntranceModifier: ViewModifier {
    var isVisible: Bool
    var delay: Double
    var offsetY: CGFloat = 22
    var offsetX: CGFloat = 0
    var startScale: CGFloat = 1
    var startRotation: Double = 0
    var startBlur: CGFloat = 0
    /// Replaces the shared entrance spring for elements wanting another feel.
    var spring: Animation?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        // Reduce Motion keeps the fade but drops every kind of travel.
        let settled = isVisible || reduceMotion

        return content
            .scaleEffect(settled ? 1 : startScale)
            .rotationEffect(.degrees(settled ? 0 : startRotation))
            .offset(
                x: settled ? 0 : offsetX,
                y: settled ? 0 : offsetY
            )
            .blur(radius: settled ? 0 : startBlur)
            .opacity(isVisible ? 1 : 0)
            .animation(
                Motion.entranceAnimation(
                    delay: delay,
                    reduceMotion: reduceMotion,
                    override: spring
                ),
                value: isVisible
            )
    }
}

extension View {
    /// Stagger this view into the entrance sequence.
    func entrance(
        _ isVisible: Bool,
        delay: Double,
        offsetY: CGFloat = 22,
        offsetX: CGFloat = 0,
        startScale: CGFloat = 1,
        startRotation: Double = 0,
        startBlur: CGFloat = 0,
        spring: Animation? = nil
    ) -> some View {
        modifier(
            EntranceModifier(
                isVisible: isVisible,
                delay: delay,
                offsetY: offsetY,
                offsetX: offsetX,
                startScale: startScale,
                startRotation: startRotation,
                startBlur: startBlur,
                spring: spring
            )
        )
    }
}
