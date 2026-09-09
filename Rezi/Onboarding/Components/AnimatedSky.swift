import Foundation
import SwiftUI

/// The gradient sky, in motion.
///
/// Two things move, and both are needed. The `MeshGradient`'s control points
/// wander, which reshapes the colour regions; and three soft lights drift
/// across on their own paths, which is what actually makes the motion legible.
/// A mesh shifting large areas of similar blue is genuinely hard to perceive —
/// a travelling highlight gives the eye something to track.
///
/// Tuned so the movement is obvious: the lights cross their paths in six to
/// ten seconds, which means visible change within a second or two rather than
/// something you have to watch for.
///
/// The control rows are deliberately weighted towards the top of the frame.
/// Only the upper part of the sky is ever visible: below that the clouds take
/// over. Spacing the rows evenly put nearly all the movement underneath them,
/// leaving the visible strip pinned and apparently static.
///
/// Every path is a sine wave, and no two share a period, so the sky never
/// repeats an arrangement and never snaps back to a start.
///
/// Below iOS 18 the mesh falls back to layered gradients; the lights still
/// drift, so the screen is alive on either path.
struct AnimatedSky: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: nil, paused: reduceMotion)) { context in
            // Frozen at the base layout when Reduce Motion is on.
            let time = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate

            ZStack {
                base(at: time)
                lights(at: time)
            }
            .compositingGroup()
        }
    }

    // MARK: - Base

    @ViewBuilder
    private func base(at time: Double) -> some View {
        if #available(iOS 18.0, *) {
            MeshGradient(
                width: 3,
                height: 4,
                points: Self.meshPoints(at: time),
                colors: ReziColor.skyMesh
            )
        } else {
            LinearGradient(
                stops: [
                    .init(color: ReziColor.skyDeep, location: 0.00),
                    .init(color: ReziColor.skyBlue, location: 0.26),
                    .init(color: ReziColor.skyIndigo, location: 0.55),
                    .init(color: ReziColor.skyPurple, location: 0.82),
                    .init(color: ReziColor.skyMagenta, location: 1.00)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    /// The 3 x 4 control grid.
    ///
    /// Edge points keep their edge coordinate so the mesh cannot tear away
    /// from the frame; they slide *along* the edge instead. Interior points
    /// move freely, and by a lot — travel has to be measured in tenths of the
    /// frame before movement in a gradient this soft reads at all.
    private static func meshPoints(at time: Double) -> [SIMD2<Float>] {
        func drift(_ speed: Double, _ phase: Double, _ amount: Double) -> Float {
            Float(sin(time * speed + phase) * amount)
        }

        return [
            // Top edge — y pinned, so it slides sideways only.
            SIMD2<Float>(0, 0),
            SIMD2<Float>(0.5 + drift(0.78, 0.0, 0.30), 0),
            SIMD2<Float>(1, 0),

            // High up, where the sky is actually visible.
            SIMD2<Float>(0, 0.20 + drift(0.70, 1.1, 0.09)),
            SIMD2<Float>(0.5 + drift(0.95, 2.0, 0.32), 0.20 + drift(0.83, 0.4, 0.11)),
            SIMD2<Float>(1, 0.20 + drift(0.63, 3.2, 0.09)),

            // Around the cloud line.
            SIMD2<Float>(0, 0.52 + drift(0.58, 2.4, 0.11)),
            SIMD2<Float>(0.5 + drift(1.06, 4.1, 0.32), 0.52 + drift(0.74, 1.7, 0.14)),
            SIMD2<Float>(1, 0.52 + drift(0.66, 0.9, 0.11)),

            // Bottom edge — y pinned.
            SIMD2<Float>(0, 1),
            SIMD2<Float>(0.5 + drift(0.88, 5.0, 0.30), 1),
            SIMD2<Float>(1, 1)
        ]
    }

    // MARK: - Drifting lights

    private struct Light {
        let color: Color
        /// Centre of its path, in unit space.
        let originX: CGFloat
        let originY: CGFloat
        /// How far it wanders either side of that centre.
        let spreadX: CGFloat
        let spreadY: CGFloat
        let speedX: Double
        let speedY: Double
        let phaseX: Double
        let phaseY: Double
        /// Radius as a fraction of the larger screen edge.
        let radius: CGFloat
        let intensity: Double
    }

    /// Two cool, one warm, all in the upper half where the sky shows.
    private static let lightSources: [Light] = [
        Light(
            color: ReziColor.skyLightCool,
            originX: 0.70, originY: 0.16,
            spreadX: 0.38, spreadY: 0.16,
            speedX: 0.74, speedY: 1.02,
            phaseX: 0.0, phaseY: 1.6,
            radius: 0.52,
            intensity: 0.70
        ),
        Light(
            color: ReziColor.skyLightWarm,
            originX: 0.30, originY: 0.44,
            spreadX: 0.42, spreadY: 0.20,
            speedX: 0.63, speedY: 0.86,
            phaseX: 2.4, phaseY: 0.7,
            radius: 0.56,
            intensity: 0.62
        ),
        Light(
            color: ReziColor.skyLightCool,
            originX: 0.45, originY: 0.30,
            spreadX: 0.34, spreadY: 0.22,
            speedX: 0.91, speedY: 0.70,
            phaseX: 4.1, phaseY: 3.3,
            radius: 0.44,
            intensity: 0.52
        )
    ]

    private func lights(at time: Double) -> some View {
        GeometryReader { geo in
            let size = geo.size
            let span = max(size.width, size.height)

            ZStack {
                ForEach(Self.lightSources.indices, id: \.self) { index in
                    let light = Self.lightSources[index]
                    let radius = span * light.radius

                    // Split out so each stays a simple expression — inline,
                    // these are slow for the type checker to resolve.
                    let swingX = CGFloat(sin(time * light.speedX + light.phaseX))
                    let swingY = CGFloat(sin(time * light.speedY + light.phaseY))
                    let x = size.width * (light.originX + swingX * light.spreadX)
                    let y = size.height * (light.originY + swingY * light.spreadY)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    light.color.opacity(light.intensity),
                                    light.color.opacity(0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: radius
                            )
                        )
                        .frame(width: radius * 2, height: radius * 2)
                        .position(x: x, y: y)
                }
            }
        }
        // Adds light rather than painting over, so the base colours survive.
        .blendMode(.plusLighter)
    }
}
