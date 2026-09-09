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

    /// The sky as a 3 x 4 mesh, read off the reference gradient: deep blue in
    /// the top-left, vivid blue across the top-right, softening through
    /// indigo and violet, into magenta along the bottom.
    ///
    /// Row order is top to bottom, each row left to right. Change these and
    /// the whole sky changes — nothing else references sky colours.
    static let skyMesh: [Color] = [
        // top
        Color(hex: 0x2B3E96), Color(hex: 0x2148C4), Color(hex: 0x1E52DE),
        // upper middle
        Color(hex: 0x34409A), Color(hex: 0x3E46B4), Color(hex: 0x5A4CC6),
        // lower middle
        Color(hex: 0x45419E), Color(hex: 0x6B4AB4), Color(hex: 0x8B4FBE),
        // bottom
        Color(hex: 0x56409C), Color(hex: 0xB14E9E), Color(hex: 0x9A4BAE)
    ]

    /// Corner colours for the pre-iOS-18 fallback, taken from the mesh.
    static let skyDeep = Color(hex: 0x2B3E96)
    static let skyBlue = Color(hex: 0x1E52DE)
    static let skyIndigo = Color(hex: 0x5A4CC6)
    static let skyPurple = Color(hex: 0x9A4BAE)
    static let skyMagenta = Color(hex: 0xB14E9E)

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

    // MARK: Stats panel

    /// The card wrapping both the stats row and the button.
    static let panelSurface = Color(hex: 0xF2F4F8)
    /// The stats row's own fill, sitting on the panel at 60%. Almost the same
    /// colour as the panel, so it reads as a barely-there inset rather than a
    /// second card.
    static let statsSurface = Color(hex: 0xE9EDF4)
    static let statsSurfaceOpacity: Double = 0.6

    static let statValue = Color.black
    static let statLabel = Color.black

    // MARK: Actions

    static let accent = Color(hex: 0x4D70EB)
    static let accentPressed = Color(hex: 0x4162D2)
    static let onAccent = Color.white
    static let signInMuted = Color(hex: 0x9A9AA3)

    // MARK: Swipe affordances

    static let swipeApply = Color(hex: 0x35C26B)
    static let swipePass = Color(hex: 0xE8604D)
}
