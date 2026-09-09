import Foundation
import SwiftUI

/// The half-donut resume-match score on each job card.
///
/// The arc sweeps up from zero when the card first appears, and sweeps again
/// each time the card is promoted to the front of the deck — so the number
/// reads as freshly scored rather than as static chrome.
struct ScoreGauge: View {
    var score: Int
    var label: String
    var color: Color
    /// True once the entrance has reached the card stack.
    var revealed: Bool
    /// True while this card is the front one.
    var isFront: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress: CGFloat = 0

    private var diameter: CGFloat { Metrics.gaugeDiameter }
    private var lineWidth: CGFloat { Metrics.gaugeLineWidth }

    var body: some View {
        VStack(spacing: 1) {
            ZStack(alignment: .bottom) {
                arc
                Text("\(score)")
                    .font(ReziFont.gaugeScore)
                    .foregroundStyle(ReziColor.cardTitle)
                    .offset(y: 2)
            }
            .frame(width: diameter, height: diameter / 2 + lineWidth / 2)

            Text(label)
                .font(ReziFont.gaugeLabel)
                .foregroundStyle(color)
        }
        .onAppear { sweep(animated: revealed) }
        .onChange(of: revealed) { _, isRevealed in
            if isRevealed { sweep(animated: true) }
        }
        .onChange(of: isFront) { _, nowFront in
            if nowFront, revealed { sweep(animated: true) }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Match score \(score) out of 100, \(label)")
    }

    // MARK: - Arc

    private var arc: some View {
        ZStack {
            // Track: the full top half.
            Circle()
                .trim(from: 0.5, to: 1.0)
                .stroke(ReziColor.gaugeTrack, style: strokeStyle)

            // Fill: from the left end, clockwise over the top.
            Circle()
                .trim(from: 0.5, to: 0.5 + 0.5 * progress)
                .stroke(color, style: strokeStyle)
        }
        .frame(width: diameter, height: diameter)
        .frame(height: diameter / 2 + lineWidth / 2, alignment: .top)
    }

    private var strokeStyle: StrokeStyle {
        StrokeStyle(lineWidth: lineWidth, lineCap: .round)
    }

    // MARK: - Sweep

    private func sweep(animated: Bool) {
        let target = CGFloat(max(0, min(100, score))) / 100

        guard animated, !reduceMotion else {
            progress = revealed ? target : 0
            return
        }

        // Snap back to empty, then fill on the next tick.
        //
        // Both in one pass would collapse into a single update, and when the
        // gauge is already full — exactly the case when a card is promoted to
        // the front — the value would not change and nothing would animate.
        progress = 0
        DispatchQueue.main.async {
            withAnimation(Motion.gaugeSweep.delay(Motion.gaugeSweepDelay)) {
                self.progress = target
            }
        }
    }
}
