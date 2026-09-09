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
    /// Deliberately shorter than the 690-of-852 background image in Figma: the
    /// gradient's full blue → violet → magenta range has to resolve inside the
    /// band that is actually visible above the cloud line, not below it.
    static let skyHeightRatio: CGFloat = 0.52
    /// Where the sky starts fading out, as a fraction of its own height.
    static let skyFadeStart: CGFloat = 0.70

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

    /// Measured from the supplied `clouds` artwork (1300 × 1658): the puffy
    /// silhouette starts 29.3% down and the image is fully opaque white by
    /// 45.1%, which is what turns the sky into the white page below.
    static let cloudAspect: CGFloat = 1300.0 / 1658.0
    static let cloudSilhouetteStart: CGFloat = 0.293

    /// How wide the cloud is drawn, as a multiple of the screen width.
    ///
    /// Figma lays the cloud band out 1990pt wide against a 393pt frame — five
    /// screens across — which is why its puffs read as large and soft rather
    /// than busy. Drawing the artwork near its native size made it look
    /// detailed and hard by comparison, so it is scaled well past the screen
    /// and only a portion is ever visible.
    static let cloudNearWidthMultiple: CGFloat = 2.1
    /// Where the silhouette should land, as a fraction of screen height.
    static let cloudNearSilhouetteY: CGFloat = 0.42
    /// Softens the photographic detail into the drawn look of the design.
    /// Set to 0 to see the artwork exactly as exported.
    static let cloudNearBlur: CGFloat = 2.5
    /// Overhang each side of the clip, so the blur's soft edge falls off
    /// screen instead of feathering the cloud against the screen edges.
    static let cloudBlurBleed: CGFloat = 8

    /// Far layer — drawn haze, so it never resolves into a hard edge.
    static let cloudFarHeightRatio: CGFloat = 0.30
    static let cloudFarTopRatio: CGFloat = 0.34
    static let cloudFarOpacity: Double = 0.5

    /// Geometry for the near cloud, positioned so its silhouette lands on
    /// target regardless of how far past the screen it is scaled.
    static func cloudNearLayout(screenSize: CGSize) -> (size: CGSize, top: CGFloat) {
        let width = screenSize.width * cloudNearWidthMultiple
        let height = width / cloudAspect
        let top = screenSize.height * cloudNearSilhouetteY - height * cloudSilhouetteStart
        return (CGSize(width: width, height: height), top)
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
