#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// Figma's Warp effect, sine-wave type, for SwiftUI's `distortionEffect`.
///
/// A distortion shader says where each output pixel reads *from*. Here every
/// pixel reads from a point pushed sideways by a sine of its height, and up or
/// down by a sine of its position across, so smooth bands in the source come
/// out gently rippled. Advancing the two phases moves the ripple through the
/// image; the slightly different wavelength across keeps the pattern from
/// ever lining up into a grid.
///
/// `amplitude` and `wavelength` are in points. The phases are expected
/// already wrapped to one turn: a long-running clock passed in raw loses its
/// precision as a 32-bit float.
[[ stitchable ]] float2 sineWarp(
    float2 position,
    float phaseX,
    float phaseY,
    float amplitude,
    float wavelength
) {
    float k = 2.0 * M_PI_F / wavelength;
    float2 shift = float2(
        sin(position.y * k + phaseX),
        sin(position.x * k * 0.85 + phaseY)
    );
    return position + shift * amplitude;
}
