import SwiftUI

/// The pale "clay" iPhone the card stack sits on.
///
/// Proportions come from the `iPhone 14 Pro - Clay` frame in Figma
/// (300 × 608.3, screen inset 15.2/12.4, island 87.8 × 24.9).
struct PhoneMockup: View {
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            if Artwork.has(Artwork.Name.phone) {
                Image(Artwork.Name.phone)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
            } else {
                drawnPhone(width: width, height: height)
            }
        }
        .accessibilityHidden(true)
    }

    private func drawnPhone(width: CGFloat, height: CGFloat) -> some View {
        let bodyWidth = width * 0.9816
        let bodyRadius = bodyWidth * 0.14

        let screenWidth = width * 0.8986
        let screenHeight = height * 0.9591
        let screenRadius = screenWidth * 0.115

        let islandWidth = width * 0.2926
        let islandHeight = height * 0.0409

        return ZStack(alignment: .top) {
            // Body
            RoundedRectangle(cornerRadius: bodyRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(hex: 0xEDEDF2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: bodyWidth, height: height)
                .shadow(color: Color(hex: 0x1B2A6B).opacity(0.18), radius: 28, x: 0, y: 18)

            // Screen
            RoundedRectangle(cornerRadius: screenRadius, style: .continuous)
                .fill(Color(hex: 0xF6F6F9))
                .frame(width: screenWidth, height: screenHeight)
                .padding(.top, height * 0.0205)

            // Dynamic Island
            Capsule(style: .continuous)
                .fill(Color(hex: 0xE2E2E9))
                .frame(width: islandWidth, height: islandHeight)
                .padding(.top, height * 0.0341)
        }
        .frame(width: width, height: height, alignment: .top)
    }
}
