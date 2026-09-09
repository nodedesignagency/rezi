import Foundation
import SwiftUI

/// The gradient sky, drifting.
///
/// On iOS 18 and up this is a real `MeshGradient` whose control points wander
/// on slow, mutually-prime sine waves — the colours never repeat a pattern and
/// never snap, they just keep moving. Edge points stay pinned to their edge so
/// the mesh can't tear away from the frame; only their position along it and
/// the interior points move.
///
/// Below iOS 18 it falls back to layered gradients using the same palette.
struct AnimatedSky: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if #available(iOS 18.0, *) {
            meshSky
        } else {
            layeredSky
        }
    }

    // MARK: - iOS 18+

    @available(iOS 18.0, *)
    private var meshSky: some View {
        // 30fps is plenty for something this slow, and halves the cost of
        // redrawing. Reduce Motion freezes it on the base layout.
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { context in
            let time = reduceMotion
                ? 0
                : context.date.timeIntervalSinceReferenceDate

            MeshGradient(
                width: 3,
                height: 4,
                points: Self.meshPoints(at: time),
                colors: ReziColor.skyMesh
            )
        }
    }

    /// The 3 x 4 control grid. Corners and edges keep their edge coordinate;
    /// everything else breathes.
    private static func meshPoints(at time: Double) -> [SIMD2<Float>] {
        func drift(speed: Double, phase: Double, amount: Double) -> Float {
            Float(sin(time * speed + phase) * amount)
        }

        return [
            // Top edge — y pinned to 0.
            SIMD2<Float>(0, 0),
            SIMD2<Float>(0.5 + drift(speed: 0.21, phase: 0.0, amount: 0.10), 0),
            SIMD2<Float>(1, 0),

            // Upper middle.
            SIMD2<Float>(0, 0.33 + drift(speed: 0.17, phase: 1.1, amount: 0.05)),
            SIMD2<Float>(0.5 + drift(speed: 0.24, phase: 2.0, amount: 0.14),
                         0.33 + drift(speed: 0.19, phase: 0.4, amount: 0.06)),
            SIMD2<Float>(1, 0.33 + drift(speed: 0.15, phase: 3.2, amount: 0.05)),

            // Lower middle.
            SIMD2<Float>(0, 0.66 + drift(speed: 0.13, phase: 2.4, amount: 0.05)),
            SIMD2<Float>(0.5 + drift(speed: 0.20, phase: 4.1, amount: 0.14),
                         0.66 + drift(speed: 0.22, phase: 1.7, amount: 0.06)),
            SIMD2<Float>(1, 0.66 + drift(speed: 0.18, phase: 0.9, amount: 0.05)),

            // Bottom edge — y pinned to 1.
            SIMD2<Float>(0, 1),
            SIMD2<Float>(0.5 + drift(speed: 0.16, phase: 5.0, amount: 0.10), 1),
            SIMD2<Float>(1, 1)
        ]
    }

    // MARK: - iOS 17

    private var layeredSky: some View {
        LinearGradient(
            stops: [
                .init(color: ReziColor.skyDeep, location: 0.00),
                .init(color: ReziColor.skyBlue, location: 0.26),
                .init(color: ReziColor.skyIndigo, location: 0.58),
                .init(color: ReziColor.skyPurple, location: 0.84),
                .init(color: ReziColor.skyMagenta, location: 1.00)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            RadialGradient(
                colors: [ReziColor.skyBlue.opacity(0.7), .clear],
                center: UnitPoint(x: 0.78, y: -0.05),
                startRadius: 0,
                endRadius: 420
            )
        }
        .overlay {
            RadialGradient(
                colors: [ReziColor.skyMagenta.opacity(0.55), .clear],
                center: UnitPoint(x: 0.45, y: 1.05),
                startRadius: 0,
                endRadius: 360
            )
        }
    }
}
