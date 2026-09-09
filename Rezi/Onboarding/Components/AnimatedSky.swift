import Foundation
import SwiftUI

/// The gradient sky, in motion.
///
/// Two things move, and both are needed. The `MeshGradient`'s control points
/// wander, which reshapes the colour regions; and a pair of soft lights drift
/// across on their own paths, which is what actually makes the motion legible.
/// The mesh alone shifts large areas of similar blue, and the eye barely
/// registers that — the travelling lights give it something to track.
///
/// Every path is built from sine waves on mutually-prime periods, so the sky
/// never repeats an arrangement and never snaps back to a start.
///
/// Below iOS 18 the mesh falls back to layered gradients; the lights still
/// drift, so the screen is alive on either path.
struct AnimatedSky: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { context in
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
    /// move freely, and by a lot — a mesh this size needs travel measured in
    /// tenths of the frame before the movement reads at all.
    private static func meshPoints(at time: Double) -> [SIMD2<Float>] {
        func drift(_ speed: Double, _ phase: Double, _ amount: Double) -> Float {
            Float(sin(time * speed + phase) * amount)
        }

        return [
            // Top edge — y pinned.
            SIMD2<Float>(0, 0),
            SIMD2<Float>(0.5 + drift(0.43, 0.0, 0.22), 0),
            SIMD2<Float>(1, 0),

            // Upper middle.
            SIMD2<Float>(0, 0.30 + drift(0.37, 1.1, 0.10)),
            SIMD2<Float>(0.5 + drift(0.53, 2.0, 0.26), 0.32 + drift(0.47, 0.4, 0.13)),
            SIMD2<Float>(1, 0.30 + drift(0.31, 3.2, 0.10)),

            // Lower middle.
            SIMD2<Float>(0, 0.66 + drift(0.29, 2.4, 0.10)),
            SIMD2<Float>(0.5 + drift(0.61, 4.1, 0.26), 0.68 + drift(0.41, 1.7, 0.13)),
            SIMD2<Float>(1, 0.66 + drift(0.34, 0.9, 0.10)),

            // Bottom edge — y pinned.
            SIMD2<Float>(0, 1),
            SIMD2<Float>(0.5 + drift(0.39, 5.0, 0.22), 1),
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

    private static let lightSources: [Light] = [
        Light(
            color: ReziColor.skyLightCool,
            originX: 0.68, originY: 0.24,
            spreadX: 0.30, spreadY: 0.20,
            speedX: 0.23, speedY: 0.31,
            phaseX: 0.0, phaseY: 1.6,
            radius: 0.62,
            intensity: 0.55
        ),
        Light(
            color: ReziColor.skyLightWarm,
            originX: 0.32, originY: 0.66,
            spreadX: 0.34, spreadY: 0.24,
            speedX: 0.19, speedY: 0.27,
            phaseX: 2.4, phaseY: 0.7,
            radius: 0.58,
            intensity: 0.45
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
        // Adds light rather than painting over, so the base colours stay.
        .blendMode(.plusLighter)
    }
}
