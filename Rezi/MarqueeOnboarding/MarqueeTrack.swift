import Foundation
import SwiftUI

/// Where a marquee row is, as a function of time.
///
/// Rather than stepping the row every frame, this keeps the last hand-off (a
/// position, a speed, and when) and works forward from it. Between hand-offs
/// the row's speed relaxes exponentially from whatever it was left at toward
/// its cruising speed, so the same few lines cover all of it:
///
/// - the gentle start, from rest up to cruising;
/// - a fling, coasting out and handing back to cruising without a seam;
/// - a tap, which catches the row and lets it pick itself back up.
///
/// Held under a finger, the row stays exactly where it was put.
struct MarqueeTrack {
    /// Position and speed at `anchorTime`, the last hand-off.
    private var anchorPosition: CGFloat = 0
    private var anchorVelocity: CGFloat = 0
    private var anchorTime: TimeInterval = 0

    /// What the row relaxes toward. Zero until the row is told to start.
    private var cruiseVelocity: CGFloat = 0

    private(set) var isHeld = false

    var settleRate: Double = Motion.Marquee.rowSettleRate

    func position(at time: TimeInterval) -> CGFloat {
        guard !isHeld else { return anchorPosition }
        let elapsed = max(0, time - anchorTime)
        let remaining = CGFloat(exp(-settleRate * elapsed))
        // The integral of the velocity below.
        return anchorPosition
            + cruiseVelocity * CGFloat(elapsed)
            + (anchorVelocity - cruiseVelocity) * (1 - remaining) / CGFloat(settleRate)
    }

    func velocity(at time: TimeInterval) -> CGFloat {
        guard !isHeld else { return 0 }
        let elapsed = max(0, time - anchorTime)
        return cruiseVelocity + (anchorVelocity - cruiseVelocity) * CGFloat(exp(-settleRate * elapsed))
    }

    /// Eases toward a new cruising speed from wherever the row is now.
    mutating func setCruise(_ velocity: CGFloat, at time: TimeInterval) {
        let current = position(at: time)
        anchorVelocity = self.velocity(at: time)
        anchorPosition = current
        anchorTime = time
        cruiseVelocity = velocity
    }

    /// Pins the row under a finger.
    mutating func hold(at position: CGFloat) {
        anchorPosition = position
        anchorVelocity = 0
        isHeld = true
    }

    /// Lets the row go from `position`, moving at `velocity`.
    mutating func release(at position: CGFloat, velocity: CGFloat, time: TimeInterval) {
        anchorPosition = position
        anchorVelocity = velocity
        anchorTime = time
        isHeld = false
    }
}
