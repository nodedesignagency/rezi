import SwiftUI

/// Type scale for the onboarding screen.
///
/// Sizes were recovered from the Figma frame by measuring each text node's
/// rendered width against SF Pro's advance widths, so they match the design
/// rather than being rounded to the nearest system text style.
enum ReziFont {

    // Hero copy
    static let headline = Font.system(size: 32, weight: .bold)
    static let subhead = Font.system(size: 15, weight: .regular)

    // Job card
    static let cardTitle = Font.system(size: 16, weight: .semibold)
    static let cardMeta = Font.system(size: 13, weight: .regular)

    // Score gauge
    static let gaugeScore = Font.system(size: 14, weight: .bold)
    static let gaugeLabel = Font.system(size: 10, weight: .semibold)

    // Stats bar
    static let statValue = Font.system(size: 16, weight: .bold)
    static let statLabel = Font.system(size: 11, weight: .medium)

    // Actions
    static let button = Font.system(size: 19, weight: .semibold)
    static let footnote = Font.system(size: 14, weight: .regular)
    static let footnoteAction = Font.system(size: 14, weight: .semibold)

    /// Overlay stamps that appear while a card is being dragged.
    static let swipeStamp = Font.system(size: 15, weight: .heavy)
}
