import SwiftUI

// The second onboarding design — "Different Style" in Figma.
//
// Its numbers live here, in `Marquee` namespaces on the shared design-system
// types, rather than mixed into the first screen's. Nothing in this file is
// read by `OnboardingView`, so either screen can be tuned without moving the
// other.

extension Metrics {
    enum Marquee {

        // MARK: Gradient

        /// Rectangle 65: 1370 × 842 at x -582, y -362 in the 393 × 852 frame.
        /// The export already carries the layer's 55% opacity, so it is drawn
        /// at full strength.
        static let gradientSize = CGSize(width: 1370, height: 842)
        static let gradientOrigin = CGPoint(x: -582, y: -362)

        /// The bottom of the export dissolves over this fraction of its height,
        /// so drift can never lift its hard lower edge into view.
        static let gradientFade: CGFloat = 0.10

        /// Extra depth, below the export's own bottom edge, that the warp is
        /// rendered over. Covers the drift and the turn.
        static let gradientOverreach: CGFloat = 64

        // MARK: Rows

        /// Every card is the first screen's 353 × 76 card at 50 / 76, which is
        /// the 232 × 50 Figma draws them at.
        static let cardScale: CGFloat = 50.0 / 76.0
        static let cardGap: CGFloat = 8

        /// Top of each row in the frame: the pair above the icon, then the pair
        /// below it.
        static let rowTops: [CGFloat] = [82, 140, 382, 440]

        /// Leading edge of each row's first card before anything moves, so the
        /// opening frame lines up with the design.
        static let rowPhases: [CGFloat] = [150, 221, 80, 30]

        /// The score gauge's centre, 304 of the card's 353. A card scores
        /// itself once this point is on screen, so the arc fills where it can
        /// be seen whichever way the row is running.
        static let gaugeCenterRatio: CGFloat = 304.0 / 353.0

        // MARK: Icon

        /// The same mark as the first screen's, at 127 rather than 80.
        static let iconSize: CGFloat = 127
        /// Centre of the icon, from the top of the frame.
        static let iconCenterY: CGFloat = 286

        /// The three rings around it, inside out. Each sits about 8 outside
        /// the last.
        static let ringSizes: [CGFloat] = [138, 153, 169]
        /// Measured off the render along each ring's diagonal.
        static let ringCornerRatio: CGFloat = 0.235
        static let ringLineWidth: CGFloat = 0.75
        /// Each ring also lifts the sky inside it slightly, so the stack reads
        /// as layered glass rather than three outlines.
        static let ringFillOpacity: Double = 0.05
        /// How much larger a ring gets at the top of its breath. Small enough
        /// that neighbouring rings never touch.
        static let ringSwell: CGFloat = 0.035

        // MARK: Tap to apply

        /// A tapped card rises slightly out of its row.
        static let appliedLift: CGFloat = 1.06
        /// The first screen's stamp is sized for a full 353-wide card. At 66%
        /// it would be too small to read, so it is set larger here.
        static let appliedBadgeScale: CGFloat = 1.35
    }
}

extension Motion {
    enum Marquee {

        // MARK: Entrance

        /// Slotted around the first screen's `Motion.Beat`, which the icon, copy,
        /// stats and button still use.
        enum Beat {
            static let gradient: Double = 0.00
            /// Rows arrive top to bottom, each sliding in the way it will run.
            static let rows: Double = 0.10
            static let rowStagger: Double = 0.07
            /// Once the icon has landed (`Motion.Beat.appIcon`), its rings
            /// ripple out one after another.
            static let rings: Double = 0.66
            static let ringStagger: Double = 0.08
        }

        /// How far a row slides as it arrives.
        static let rowEntranceTravel: CGFloat = 48

        // MARK: Rows

        /// Cruising speed of each row, in points per second at design scale.
        /// Directions alternate, and no two rows share a speed, so the feed
        /// never moves in lockstep.
        static let rowSpeeds: [CGFloat] = [26, 21, 23, 28]

        /// How quickly a row returns to cruising after it is let go, thrown or
        /// tapped, per second. At 2 a hard fling coasts for about a second and
        /// a half before the row is back at its own pace.
        static let rowSettleRate: Double = 2.0

        /// Flings are capped at this speed, so a flick cannot spin a row.
        static let rowMaxFling: CGFloat = 2600

        // MARK: Tap to apply

        static let applyIn = Animation.spring(response: 0.3, dampingFraction: 0.62)
        static let applyOut = Animation.easeOut(duration: 0.35)
        /// How long the stamp holds before the card settles back into the row.
        static let applyHold: TimeInterval = 0.9

        // MARK: Gradient

        /// The export sways and turns about its own centre. Every period is
        /// different, so it never repeats a pose, and all three start at zero
        /// so the first frame is the Figma composition.
        static let driftX: CGFloat = 34
        static let driftY: CGFloat = 18
        static let driftAngle: Double = 6
        static let driftSpeedX: Double = 0.38
        static let driftSpeedY: Double = 0.29
        static let driftSpeedAngle: Double = 0.21

        /// Figma's Warp effect (sine wave, amplitude 5.2, scale 0.5), run live.
        /// In points here rather than Figma's units, and tuned by eye against
        /// the export.
        static let warpAmplitude: CGFloat = 22
        static let warpWavelength: CGFloat = 460
        static let warpSpeedX: Double = 0.8
        static let warpSpeedY: Double = 0.62
        /// The ripple builds up over this long rather than starting at full
        /// strength, so the opening frame is still the export as supplied.
        static let warpWake: Double = 2.5

        // MARK: Rings

        /// One breath every three and a half seconds, passing outward: each
        /// ring peaks a moment after the one inside it.
        static let ringBreathSpeed: Double = 1.8
        static let ringBreathLag: Double = 0.7
    }
}

extension ReziColor {
    enum Marquee {
        /// Get Started and Sign in. This design moves the first screen's blue
        /// to a deep purple.
        static let accent = Color(hex: 0x621E97)
        static let accentPressed = Color(hex: 0x521880)

        /// Hairline around each of the icon's rings.
        static let ring = Color(hex: 0x621E97).opacity(0.2)

        /// Rectangle 65's radial stops. Only used to draw the gradient when the
        /// export is missing; the last stop is white.
        static let gradientCenter = Color(hex: 0xCC97F4)
        static let gradientMid = Color(hex: 0x722BFF)
        static let gradientOpacity: Double = 0.55
    }
}

extension Artwork.Name {
    static let marqueeGradient = "MarqueeGradient"
}
