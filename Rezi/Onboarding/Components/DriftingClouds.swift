import SwiftUI

/// The stand-in when no cloud artwork is present.
///
/// Blobs are inset from both edges of the band, so two copies laid side by
/// side meet on empty pixels and the loop is seamless without mirroring.
struct DriftingBlobClouds: View {
    var band: Band
    var loopDuration: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = 0

    enum Band {
        case far, near

        /// Fractions of the band's own size, so the layer resolves at any width.
        var blobs: [CloudBlob] {
            switch self {
            case .far:
                return [
                    CloudBlob(x: 0.16, y: 0.44, width: 0.30, height: 0.52, opacity: 0.55),
                    CloudBlob(x: 0.38, y: 0.30, width: 0.26, height: 0.44, opacity: 0.45),
                    CloudBlob(x: 0.62, y: 0.48, width: 0.32, height: 0.56, opacity: 0.50),
                    CloudBlob(x: 0.84, y: 0.34, width: 0.22, height: 0.40, opacity: 0.40)
                ]
            case .near:
                return [
                    CloudBlob(x: 0.14, y: 0.62, width: 0.42, height: 0.78, opacity: 0.95),
                    CloudBlob(x: 0.36, y: 0.50, width: 0.34, height: 0.62, opacity: 0.85),
                    CloudBlob(x: 0.56, y: 0.66, width: 0.44, height: 0.84, opacity: 1.00),
                    CloudBlob(x: 0.78, y: 0.54, width: 0.36, height: 0.66, opacity: 0.90)
                ]
            }
        }
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            HStack(spacing: 0) {
                CloudBandShapes(blobs: band.blobs).frame(width: width, height: height)
                CloudBandShapes(blobs: band.blobs).frame(width: width, height: height)
            }
            .frame(width: width * 2, height: height, alignment: .leading)
            .offset(x: -phase * width)
            .onAppear {
                guard !reduceMotion, phase == 0 else { return }
                withAnimation(.linear(duration: loopDuration).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
        }
        .allowsHitTesting(false)
    }
}

/// One cloud puff, positioned as a fraction of its band.
struct CloudBlob {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var opacity: Double
}

/// Clouds the way the design builds them: heavily blurred rounded rectangles,
/// stacked and overlapping.
struct CloudBandShapes: View {
    var blobs: [CloudBlob]

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                ForEach(Array(blobs.enumerated()), id: \.offset) { entry in
                    let blob = entry.element
                    let blobWidth = size.width * blob.width
                    let blobHeight = size.height * blob.height

                    RoundedRectangle(cornerRadius: blobHeight / 2, style: .continuous)
                        .fill(Color.white.opacity(blob.opacity))
                        .frame(width: blobWidth, height: blobHeight)
                        .blur(radius: max(12, blobHeight * 0.22))
                        .position(x: size.width * blob.x, y: size.height * blob.y)
                }
            }
        }
    }
}
