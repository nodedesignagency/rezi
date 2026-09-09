import SwiftUI

/// Every number here is read straight off the 393 × 852 Figma frame
/// (`node-id=1-342`), so tweaking the design means editing this one file.
enum Metrics {

    /// The artboard the design was drawn on.
    static let designWidth: CGFloat = 393
    static let designHeight: CGFloat = 852

    /// How much of the screen height the sky gradient covers before it
    /// dissolves into white. Background image in Figma is 690pt of 852.
    static let skyHeightRatio: CGFloat = 0.81

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

    /// Near layer: how tall the cloud is drawn, as a fraction of the screen.
    static let cloudNearHeightRatio: CGFloat = 0.74
    /// Where its silhouette should land, as a fraction of screen height.
    static let cloudNearSilhouetteY: CGFloat = 0.41

    /// Far layer — soft, distant haze drawn above the near clouds.
    static let cloudFarHeightRatio: CGFloat = 0.30
    static let cloudFarTopRatio: CGFloat = 0.36
    static let cloudFarOpacity: Double = 0.55

    /// Top edge of the near cloud image, so its silhouette lands on target.
    static func cloudNearTop(screenHeight: CGFloat) -> CGFloat {
        let tileHeight = screenHeight * cloudNearHeightRatio
        return screenHeight * cloudNearSilhouetteY - tileHeight * cloudSilhouetteStart
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
