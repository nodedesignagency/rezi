import SwiftUI

/// The round company logo on a job card.
///
/// Uses `CompanyLogo1…N` if any were dropped in, then `CompanyLogo`, and
/// otherwise draws a placeholder mark so the card is never missing its avatar.
struct CompanyMark: View {
    var index: Int
    var size: CGFloat

    var body: some View {
        Group {
            if let name = Artwork.companyLogo(preferring: index) {
                Image(name)
                    .resizable()
                    .scaledToFill()
            } else {
                drawnMark
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .accessibilityHidden(true)
    }

    /// A simple geometric stand-in — a white ring cut by two bars — that reads
    /// as a corporate mark without impersonating a real one.
    private var drawnMark: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x1B62C4), Color(hex: 0x0E4894)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .strokeBorder(Color.white, lineWidth: size * 0.075)
                .padding(size * 0.22)

            Rectangle()
                .fill(Color.white)
                .frame(width: size * 0.075, height: size * 0.46)

            Rectangle()
                .fill(Color.white)
                .frame(width: size * 0.46, height: size * 0.075)
        }
    }
}
