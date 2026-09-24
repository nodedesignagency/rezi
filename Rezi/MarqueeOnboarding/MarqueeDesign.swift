import SwiftUI

// The second onboarding design — "Different Style" in Figma.
//
// Its numbers live here, in `Marquee` namespaces on the shared design-system
// types, rather than mixed into the first screen's. Nothing in this file is
// read by `OnboardingView`, so either screen can be tuned without moving the
// other.

extension Metrics {
    enum Marquee {

        // MARK: Ribbon

        // Rectangle 65, drawn in code rather than from its export. In Figma it
        // is a radial fill, #CC97F4 → #722BFF at 35% → white, on a layer at 55%
        // with a sine-wave Warp. The geometry below was fitted to that export
        // and reproduces it to within about 2% per pixel. All of it is in the
        // 393 × 852 frame's points.

        /// Centre of the ellipse.
        static let ribbonCenter = CGPoint(x: 102.6, y: 58.4)
        /// Its semi-axes, out to the white stop: very long, and thin, which is
        /// what makes it read as a ribbon rather than a glow.
        static let ribbonRadii = CGSize(width: 1602, height: 308)
        /// Rising to the right.
        static let ribbonAngle: Double = -28.9
        static let ribbonCoreStop: CGFloat = 0.35

        /// Figma's Warp, as fitted: the ribbon is bent up and down by 25 along
        /// a wave 1108 long, which gives it its slight S. The phase is measured
        /// from the frame's left edge.
        static let ribbonBend: CGFloat = 25.2
        static let ribbonBendWavelength: CGFloat = 1108
        static let ribbonBendPhase: Double = 5.703

        /// How far down the page the ribbon is drawn. It has faded to white
        /// well before this, in every pose it drifts through.
        static let ribbonReach: CGFloat = 544
        /// The bottom of that band dissolves, in case it has not quite.
        static let ribbonFade: CGFloat = 0.15

        // MARK: Rows

        /// Every card is the first screen's 353 × 76 card at 50 / 76, which is
        /// the 232 × 50 Figma draws them at.
        static let cardScale: CGFloat = 50.0 / 76.0
        static let cardGap: CGFloat = 8

        /// Top of the first row in the frame. Each row sits one card and one
        /// gap below the one above it in its pair.
        static let firstRowTop: CGFloat = 82

        /// Figma: 26 between the bottom row and the headline. The lower pair is
        /// placed from the headline rather than from the top of the screen, so
        /// this holds on every phone; the copy sets taller on a device than in
        /// Figma, and placing those rows by ratio let the headline ride up
        /// into them.
        static let rowsToHeadline: CGFloat = 26
        /// Figma's text box starts at the capitals; SwiftUI's starts at the top
        /// of the line, about 8 above them at 32 pt in SF Pro and Inter alike.
        /// The 26 is kept to the capitals, which is the gap the eye reads.
        static let headlineCapInset: CGFloat = 8
        /// Where the copy starts before it has been measured, for the very
        /// first layout pass. Nothing is visible yet at that point.
        static let copyTopFallback: CGFloat = 508

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
        /// The space between the two pairs of rows in the frame, 190 to 382.
        /// The icon and its rings sit centred in it, and scale down with it on
        /// a phone that has less of it to give.
        static let iconSpace: CGFloat = 192

        /// The three rings around it, inside out. Each sits about 8 outside
        /// the last.
        static let ringSizes: [CGFloat] = [138, 153, 169]
        /// Measured off the render along each ring's diagonal.
        static let ringCornerRatio: CGFloat = 0.235
        static let ringLineWidth: CGFloat = 0.75
        /// Each ring also lifts the sky inside it slightly, so the stack reads
        /// as layered glass rather than three outlines.
        static let ringFillOpacity: Double = 0.05
        static let ringStrokeOpacity: Double = 0.2

        // MARK: Pulse

        /// A pulse is a faint ring leaving the icon and travelling out through
        /// the other three, each lighting up as it passes. It grows from the
        /// icon's edge to this, just past the outer ring, and has faded to
        /// nothing by the time it gets there.
        static let pulseMaxSize: CGFloat = 200
        static let pulseLineWidth: CGFloat = 1.25
        static let pulseOpacity: Double = 0.6

        /// How close, in points, the travelling ring has to be to a ring to
        /// light it: roughly the gap between two rings.
        static let pulseReach: CGFloat = 9
        /// A lit ring: how much it swells, and how much stronger its line and
        /// its fill get. Small enough that neighbouring rings never touch.
        static let pulseSwell: CGFloat = 0.045
        static let pulseStrokeGain: Double = 0.45
        static let pulseFillGain: Double = 0.10
        /// How much the icon itself swells as each pulse leaves it.
        static let pulseBeatScale: CGFloat = 0.03

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

        // MARK: Ribbon

        // Because the ribbon is drawn rather than supplied, its shape itself
        // can move, not just its position. Every motion is a sine from zero,
        // so the first frame is the Figma composition, and no two share a
        // period, so it never repeats a pose.

        /// The centre wanders.
        static let driftX: CGFloat = 34
        static let driftY: CGFloat = 18
        static let driftSpeedX: Double = 0.38
        static let driftSpeedY: Double = 0.29
        /// It turns either side of its angle.
        static let driftAngle: Double = 5
        static let driftSpeedAngle: Double = 0.21
        /// It lengthens and shortens, and thickens and thins, as a fraction
        /// of its size.
        static let stretch: CGFloat = 0.06
        static let stretchSpeed: Double = 0.23
        static let swell: CGFloat = 0.10
        static let swellSpeed: Double = 0.41
        /// Its lighter core grows and shrinks inside the purple band.
        static let coreShift: CGFloat = 0.05
        static let coreSpeed: Double = 0.37

        /// The S-bend travels along it like a slow wave down a flag, radians
        /// per second: about twenty seconds for a full pass.
        static let bendSpeed: Double = 0.3

        /// A finer ripple on top, in points.
        static let rippleAmplitude: CGFloat = 12
        static let rippleWavelength: CGFloat = 460
        static let rippleSpeedX: Double = 0.8
        static let rippleSpeedY: Double = 0.62
        /// The ripple builds up over this long rather than starting at full
        /// strength, so the opening frame is the design.
        static let rippleWake: Double = 2.5

        // MARK: Pulse

        /// One pulse every this many seconds.
        static let pulsePeriod: Double = 2.6
        /// The part of each period the travelling ring is out; the rest is a
        /// rest before the next one.
        static let pulseTravel: Double = 0.75
        /// The part of each period the icon's beat takes.
        static let pulseBeatLength: Double = 0.12
        /// The first pulse waits for the rings to finish arriving.
        static let pulseStartDelay: Double = 1.2
    }
}

extension ReziColor {
    enum Marquee {
        /// Get Started and Sign in. This design moves the first screen's blue
        /// to a deep purple.
        static let accent = Color(hex: 0x621E97)
        static let accentPressed = Color(hex: 0x521880)

        /// The icon's rings and its pulse, at the opacities in `Metrics.Marquee`.
        static let ring = Color(hex: 0x621E97)

        /// Rectangle 65's radial stops, as set in Figma. The last is white.
        static let ribbonCore = Color(hex: 0xCC97F4)
        static let ribbonBand = Color(hex: 0x722BFF)
        /// The layer's opacity in Figma.
        static let ribbonOpacity: Double = 0.55
    }
}
