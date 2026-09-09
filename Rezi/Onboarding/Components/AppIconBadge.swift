import SwiftUI

/// The Rezi mark above the headline.
///
/// It arrives on its own beat — a slight overshoot and untwist — so it reads
/// as the moment the brand lands, rather than as one more thing fading in.
struct AppIconBadge: View {
    var appeared: Bool
    var size: CGFloat = Metrics.appIconSize

    var body: some View {
        Group {
            if Artwork.has(Artwork.Name.appIcon) {
                Image(Artwork.Name.appIcon)
                    .resizable()
                    .scaledToFit()
            } else {
                drawnIcon
            }
        }
        .frame(width: size, height: size)
        .shadow(color: Color(hex: 0x3B1470).opacity(0.28), radius: 16, x: 0, y: 8)
        .entrance(
            appeared,
            delay: Motion.Beat.appIcon,
            offsetY: 8,
            startScale: 0.6,
            startRotation: -12,
            spring: Motion.appIconSpring
        )
        .accessibilityHidden(true)
    }

    /// Stand-in for `ReziIcon`: the purple tile with a white R.
    private var drawnIcon: some View {
        RoundedRectangle(cornerRadius: size * 0.225, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color(hex: 0x8E29D6), Color(hex: 0x6A15B4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Text("R")
                    .font(.system(size: size * 0.62, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
    }
}
