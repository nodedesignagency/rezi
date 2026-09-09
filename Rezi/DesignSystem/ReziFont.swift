import SwiftUI

/// Type scale for the onboarding screen.
///
/// Everything routes through `InterFont`, so the screen is set in Inter when
/// the font files are bundled and in SF Pro at the same sizes when they are not.
///
/// Sizes marked "from Figma" were read straight off the inspector. The rest
/// were recovered by measuring each text node's rendered width against the
/// font's advance widths.
enum ReziFont {

    // Hero copy — from Figma
    static let headline = InterFont.font(size: 32, weight: .medium)
    static let subhead = InterFont.font(size: 14, weight: .regular)

    /// Both carry -2% letter spacing.
    static let headlineTracking: CGFloat = -0.64
    static let subheadTracking: CGFloat = -0.28

    /// The subhead sets at 140% line height; the headline is on Auto, which
    /// is already the system default. `lineSpacing` is measured on top of the
    /// default line box, so this is the difference, not the whole value.
    static let subheadLineSpacing: CGFloat = 2.7

    // Job card
    static let cardTitle = InterFont.font(size: 16, weight: .semibold)
    static let cardMeta = InterFont.font(size: 13, weight: .regular)

    // Score gauge
    static let gaugeScore = InterFont.font(size: 14, weight: .bold)
    static let gaugeLabel = InterFont.font(size: 10, weight: .semibold)

    // Stats — from Figma
    static let statValue = InterFont.font(size: 14, weight: .medium)
    static let statLabel = InterFont.font(size: 10, weight: .regular)
    /// Figma sets -1% letter spacing on the stat value.
    static let statValueTracking: CGFloat = -0.14

    // Actions
    static let button = InterFont.font(size: 19, weight: .semibold)
    static let footnote = InterFont.font(size: 14, weight: .regular)
    static let footnoteAction = InterFont.font(size: 14, weight: .semibold)

    /// Overlay stamps that appear while a card is being dragged.
    static let swipeStamp = InterFont.font(size: 15, weight: .heavy)
}
