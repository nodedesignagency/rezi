import SwiftUI

/// Every number here is read straight off the 393 × 852 Figma frame
/// (`node-id=1-342`), so tweaking the design means editing this one file.
enum Metrics {

    /// The artboard the design was drawn on.
    static let designWidth: CGFloat = 393
    static let designHeight: CGFloat = 852

    /// How much of the screen height the sky covers before it dissolves into
    /// the clouds.
    ///
    /// Figma keeps blue visible down the left and right margins to roughly
    /// two thirds of the screen — the middle only looks white because the
    /// phone body covers it. Cutting the sky short made the gradient a thin
    /// strip at the top, where the mesh's pinned top row barely moves, which
    /// is most of why the animation could not be seen.
    static let skyHeightRatio: CGFloat = 0.74

    /// Where the sky starts fading out, as a fraction of its own height.
    static let skyFadeStart: CGFloat = 0.74

    // MARK: - Hero (phone + card stack)

    /// Clay iPhone mockup: x 47, y 80.6, 300 × 608.3.
    static let phoneWidth: CGFloat = 300
    static let phoneHeight: CGFloat = 608.3
    static let phoneTop: CGFloat = 80.6

    /// Front card: x 20, y 150, 353 × 76.
    static let cardWidth: CGFloat = 353
    static let cardHeight: CGFloat = 76
    static let cardTop: CGFloat = 150
    static let cardCornerRadius: CGFloat = 16

    /// Cards behind the front one step down 0.9× each and slide downward.
    /// Figma: 353 / 317.7 / 285.93 wide at y 150 / 191.8 / 230.
    static let cardDepthScale: CGFloat = 0.9
    private static let cardDepthOffsets: [CGFloat] = [0, 41.8, 80, 113]

    static func cardScale(depth: Int) -> CGFloat {
        CGFloat(pow(Double(cardDepthScale), Double(max(0, depth))))
    }

    static func cardOffsetY(depth: Int) -> CGFloat {
        let d = max(0, depth)
        guard d < cardDepthOffsets.count else { return cardDepthOffsets.last ?? 0 }
        return cardDepthOffsets[d]
    }

    /// How many cards are kept in the view tree. The deepest one is drawn at
    /// zero opacity so it can fade in as the stack promotes.
    static let visibleCardCount = 4
    static let hiddenCardDepth = 3

    // MARK: - Job card internals (front card, 353 × 76)

    static let cardLogoSize: CGFloat = 36
    static let cardPaddingLeading: CGFloat = 20
    static let cardPaddingTrailing: CGFloat = 17.4
    static let cardLogoToText: CGFloat = 12
    static let cardTitleToMeta: CGFloat = 4
    static let cardMetaDividerHeight: CGFloat = 10

    /// Gauge arc: 62.77 across in Figma, drawn inside a 98pt-wide slot.
    static let gaugeDiameter: CGFloat = 63
    static let gaugeLineWidth: CGFloat = 7

    // MARK: - Content column

    /// The content column is 353 wide at x 20 in the 393 frame.
    static let contentHorizontalPadding: CGFloat = 20

    static let appIconSize: CGFloat = 80

    /// Gaps below each element, derived from the Figma y-positions after
    /// accounting for SF Pro's ascent/descent padding inside a Text frame.
    static let iconToHeadline: CGFloat = 20
    static let headlineToSubhead: CGFloat = 14
    static let subheadToStats: CGFloat = 28
    static let panelToSignIn: CGFloat = 16

    // MARK: Stats panel
    //
    // Figma wraps the stats row *and* the button in one 353 x 140 frame with
    // 4pt padding and a 4pt gap: 4 + 76 + 4 + 52 + 4 = 140. The button is
    // inside the card, not below it.

    static let panelPadding: CGFloat = 4
    static let panelGap: CGFloat = 4
    /// Corner radius is "Mixed" in Figma: the bottom hugs the button's pill
    /// (26 + 4 of padding), the top sits tighter.
    static let panelTopRadius: CGFloat = 24
    static let panelBottomRadius: CGFloat = 30

    static let statsHeight: CGFloat = 76
    /// Figma reads 60, which Figma itself clamps to half the height.
    static let statsCornerRadius: CGFloat = 38

    static let statsDividerHeight: CGFloat = 42
    static let statsDividerWidth: CGFloat = 1
    /// The divider is a black gradient that fades out at both ends, the whole
    /// path drawn at 10%.
    static let statsDividerOpacity: Double = 0.10

    static let buttonHeight: CGFloat = 52
    static let buttonCornerRadius: CGFloat = 26

    // MARK: - Clouds

    /// Wide enough that puffs stay large and soft, but no wider.
    ///
    /// At five screens across the artwork's alpha ramp stretched over 313pt of
    /// screen, leaving the cloud only 22% opaque where the app icon sits and
    /// putting its dense half below the fade — so all that ever showed was a
    /// washed-out wisp. Narrower compresses that ramp back into the band where
    /// the cloud is actually meant to be seen.
    static let cloudBandWidthRatio: CGFloat = 2.8
    static let cloudBandLeftRatio: CGFloat = -0.9
    /// Taken from the export rather than the Figma frame, so the artwork is
    /// never stretched. Update if the cloud is re-exported at a different crop.
    static let cloudBandAspect: CGFloat = 3980.0 / 1681.0

    /// Measured off the export: its wisps become visible a quarter of the way
    /// down. The band is positioned from this rather than from its top edge,
    /// so re-exporting at a different crop only needs this number changed.
    static let cloudSilhouetteStart: CGFloat = 0.255

    /// Where those wisps should land, as a fraction of screen height.
    ///
    /// Measured off the Figma render: cloud tops read 43% at the left edge,
    /// 44% mid-screen, and the sky ends at 43% on the right. The app icon
    /// sits at 48-57%, so it lands just under the cloud line and reads as the
    /// divider between the phone above and the copy below.
    static let cloudSilhouetteY: CGFloat = 0.43
    static let cloudFarSilhouetteY: CGFloat = 0.39

    /// How far the band slides each way, as a fraction of screen width. It is
    /// wide enough that it never runs out at this amplitude, so the drift
    /// needs no tiling and can never show a seam.
    static let cloudDriftTravel: CGFloat = 0.55

    /// The artwork peaks at 94% alpha and ramps very gradually, so a single
    /// pass reads thin. Drawing it more than once compounds coverage —
    /// 1-(1-a)^n — which thickens the cloud without shrinking its puffs or
    /// touching the artwork.
    static let cloudDensity: Int = 3

    /// A second, smaller copy drawn behind for parallax.
    static let cloudFarScale: CGFloat = 0.7
    static let cloudFarOpacity: Double = 0.45

    /// The cloud dissolves to nothing across this band, so the content below
    /// sits on clean white instead of on cloud texture.
    static let cloudFadeStart: CGFloat = 0.62
    static let cloudFadeEnd: CGFloat = 0.82

    /// Top edge of a cloud band, placed so its wisps land on `silhouetteY`.
    static func cloudBandTop(
        screenSize: CGSize,
        bandHeight: CGFloat,
        silhouetteY: CGFloat
    ) -> CGFloat {
        screenSize.height * silhouetteY - bandHeight * cloudSilhouetteStart
    }

    // MARK: - Glow behind the phone

    /// Ellipse 7184: x -108, y 370, 578 × 250.
    static let glowWidth: CGFloat = 578
    static let glowHeight: CGFloat = 250
    static let glowCenterY: CGFloat = 495

    // MARK: - Swipe

    /// Horizontal drag past this commits the swipe.
    static let swipeCommitDistance: CGFloat = 96
    /// Degrees of tilt at full commit distance.
    static let swipeMaxRotation: Double = 12
    /// Where a flung card lands, well past any screen edge.
    static let swipeExitDistance: CGFloat = 620

    /// Scales the hero to the current screen while the content column keeps
    /// its natural point sizes, the way a real app would lay this out.
    static func heroScale(for width: CGFloat) -> CGFloat {
        min(width / designWidth, 1.25)
    }
}
