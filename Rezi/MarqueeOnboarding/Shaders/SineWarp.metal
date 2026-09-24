#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// Figma's Warp effect, sine-wave type, for SwiftUI's `distortionEffect`.
///
/// A distortion shader says where each output pixel reads *from*. Two sine
/// waves decide that here:
///
/// - The bend: every pixel reads from a point pushed up or down by a long,
///   gentle sine of its position across. This is the Warp from the design,
///   fitted to its export, and what gives the ribbon its slight S. Advancing
///   its phase sends the S travelling along the ribbon.
/// - The ripple: a finer wave in both directions on top, so the edges keep
///   moving in small ways too.
///
/// Amplitudes are in points and wave numbers in radians per point. Phases are
/// expected already wrapped to one turn: a long-running clock passed in raw
/// loses its precision as a 32-bit float.
[[ stitchable ]] float2 sineWarp(
    float2 position,
    float bendAmplitude,
    float bendWaveNumber,
    float bendPhase,
    float rippleAmplitude,
    float rippleWaveNumber,
    float ripplePhaseX,
    float ripplePhaseY
) {
    float bend = sin(position.x * bendWaveNumber + bendPhase) * bendAmplitude;
    float2 ripple = float2(
        sin(position.y * rippleWaveNumber + ripplePhaseX),
        sin(position.x * rippleWaveNumber * 0.85 + ripplePhaseY)
    ) * rippleAmplitude;
    return position + float2(0.0, bend) + ripple;
}
