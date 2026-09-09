import SwiftUI

extension Color {
    /// `Color(hex: 0x5B6CF0)` — sRGB, no string parsing.
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

/// Palette sampled from the onboarding frame in Figma.
enum ReziColor {

    // MARK: Sky

    /// Deep blue in the top-left corner of the gradient.
    static let skyDeep = Color(hex: 0x1B3AC6)
    /// Brighter blue across the top edge.
    static let skyBlue = Color(hex: 0x2B4BD4)
    /// The blue → purple hand-off, roughly two thirds down.
    static let skyIndigo = Color(hex: 0x5B49D6)
    /// Purple in the bottom-right corner.
    static let skyPurple = Color(hex: 0x8B44CE)

    /// Everything below the sky.
    static let page = Color.white

    // MARK: Cards

    static let cardSurface = Color.white
    static let cardTitle = Color(hex: 0x101014)
    static let cardMeta = Color(hex: 0x8B8B93)
    static let cardDivider = Color(hex: 0xD8D8E0)

    // MARK: Score gauge

    static let gaugeTrack = Color(hex: 0xE9E9EE)
    /// 0–39
    static let scoreWeak = Color(hex: 0xE8604D)
    /// 40–69 — "Good"
    static let scoreGood = Color(hex: 0xE8A33D)
    /// 70+ — "Best"
    static let scoreBest = Color(hex: 0x35C26B)

    // MARK: Copy

    static let headline = Color(hex: 0x08080A)
    static let subhead = Color(hex: 0x64646E)

    // MARK: Stats

    static let statsSurface = Color(hex: 0xF1F1F6)
    static let statValue = Color(hex: 0x101014)
    static let statLabel = Color(hex: 0x8B8B93)
    static let statDivider = Color(hex: 0xDFDFE6)

    // MARK: Actions

    static let accent = Color(hex: 0x5B6CF0)
    static let accentPressed = Color(hex: 0x4E5EDC)
    static let onAccent = Color.white
    static let signInMuted = Color(hex: 0x9A9AA3)

    // MARK: Swipe affordances

    static let swipeApply = Color(hex: 0x35C26B)
    static let swipePass = Color(hex: 0xE8604D)
}
