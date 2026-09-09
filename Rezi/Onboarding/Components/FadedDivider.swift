import SwiftUI

/// A hairline that fades out at both ends rather than stopping flat.
///
/// Figma draws every divider in the screen this way: a 1pt path stroked with
/// a black gradient running transparent → solid → transparent, the whole path
/// at 10%. Shared so the card's meta separator and the stats bar's columns
/// stay the same mark at different lengths.
struct FadedDivider: View {
    var height: CGFloat

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0), location: 0),
                        .init(color: .black, location: 0.5),
                        .init(color: .black.opacity(0), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: Metrics.dividerWidth, height: height)
            .opacity(Metrics.dividerOpacity)
    }
}
