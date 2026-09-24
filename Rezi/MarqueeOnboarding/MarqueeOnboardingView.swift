import SwiftUI

/// The second onboarding design: the job feed streams past in four rows, with
/// the Rezi mark held between them.
///
/// The copy, stats, button and sign-in are the first screen's, reused as they
/// are, so the two designs differ only in the hero. Where the first shows one
/// deck swiped a card at a time, this shows the feed: rows running in
/// alternate directions over a drifting purple ribbon, which can be grabbed,
/// thrown, and tapped to apply.
///
/// Sizes scale with the screen's width, as in the first screen, and the copy
/// column is anchored to the bottom safe area. The rows are placed from both
/// ends: the top pair from the top of the screen, the bottom pair a fixed gap
/// above the headline, and the icon centred in whatever lies between. As in the
/// first screen, a single `appeared` flag drives the entrance.
struct MarqueeOnboardingView: View {
    var onGetStarted: () -> Void = {}
    var onSignIn: () -> Void = {}

    @State private var appeared = false
    /// Top of the copy column in window coordinates, once laid out.
    @State private var copyTop: CGFloat?

    var body: some View {
        ZStack(alignment: .top) {
            FlowingGradient(appeared: appeared)

            GeometryReader { geo in
                hero(in: geo.size, originY: geo.frame(in: .global).minY)
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 0)
                contentColumn
                    // Measured on the column rather than the headline, whose
                    // entrance offset would move the rows with it.
                    .background {
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: CopyTopKey.self,
                                value: geo.frame(in: .global).minY
                            )
                        }
                    }
            }
            .padding(.horizontal, Metrics.contentHorizontalPadding)
            .padding(.bottom, 8)
        }
        .background(ReziColor.page.ignoresSafeArea())
        .onPreferenceChange(CopyTopKey.self) { copyTop = $0 }
        .task {
            // Let the pre-animation state render for a frame, so the springs
            // have something to travel from.
            guard !appeared else { return }
            try? await Task.sleep(for: Motion.entranceLeadIn)
            appeared = true
        }
    }

    // MARK: - Hero

    /// One row of the feed: which way it runs, and how fast.
    private struct Lane {
        let cards: [JobCard]
        let direction: SwipeDirection
        let speed: CGFloat
        let phase: CGFloat
    }

    /// Right, left, right, left: the pair above the icon, then the pair below.
    private static let lanes: [Lane] = JobCard.marqueeRows.indices.map { index in
        Lane(
            cards: JobCard.marqueeRows[index],
            direction: index.isMultiple(of: 2) ? .right : .left,
            speed: Motion.Marquee.rowSpeeds[index],
            phase: Metrics.Marquee.rowPhases[index]
        )
    }

    /// - Parameter originY: The hero's own top in window coordinates, to bring
    ///   the measured copy column into its space.
    private func hero(in size: CGSize, originY: CGFloat) -> some View {
        let scale = Metrics.heroScale(for: size.width)
        let vScale = size.height / Metrics.designHeight
        let cardHeight = Metrics.cardHeight * Metrics.Marquee.cardScale * scale
        let rowStep = cardHeight + Metrics.Marquee.cardGap * scale

        // The top pair hangs from the top of the screen, as in the design.
        let upperTop = Metrics.Marquee.firstRowTop * vScale

        // The bottom pair sits the design's gap above the headline's capitals.
        let copyY = copyTop.map { $0 - originY } ?? Metrics.Marquee.copyTopFallback * vScale
        let lowerBottom = copyY + Metrics.Marquee.headlineCapInset - Metrics.Marquee.rowsToHeadline
        let lowerTop = lowerBottom - cardHeight - rowStep

        func rowTop(_ index: Int) -> CGFloat {
            index < 2
                ? upperTop + CGFloat(index) * rowStep
                : lowerTop + CGFloat(index - 2) * rowStep
        }

        // The icon fills the space between the pairs as it does in the design,
        // shrinking only on a phone with less of it to give.
        let spaceTop = upperTop + rowStep + cardHeight
        let space = max(0, lowerTop - spaceTop)
        let iconScale = max(scale * 0.5, min(scale, space / Metrics.Marquee.iconSpace))
        let outerRing = (Metrics.Marquee.ringSizes.last ?? Metrics.Marquee.iconSize) * iconScale
        let iconY = spaceTop + space / 2

        return ZStack(alignment: .top) {
            // Beneath the rows, so a pulse spreading past the outer ring
            // passes under the cards rather than over them.
            IconHalo(appeared: appeared, scale: iconScale)
                .offset(y: iconY - outerRing / 2)

            ForEach(Self.lanes.indices, id: \.self) { index in
                let lane = Self.lanes[index]

                MarqueeRow(
                    cards: lane.cards,
                    direction: lane.direction,
                    speed: lane.speed * scale,
                    phase: lane.phase * scale,
                    cardScale: Metrics.Marquee.cardScale * scale,
                    gap: Metrics.Marquee.cardGap * scale,
                    width: size.width,
                    appeared: appeared
                )
                .offset(y: rowTop(index))
                // Slides in the way it is about to run.
                .entrance(
                    appeared,
                    delay: Motion.Marquee.Beat.rows + Double(index) * Motion.Marquee.Beat.rowStagger,
                    offsetY: 0,
                    offsetX: -lane.direction.sign * Motion.Marquee.rowEntranceTravel
                )
            }
        }
        .frame(width: size.width, height: size.height, alignment: .top)
    }

    // MARK: - Content

    /// The first screen's column, less the icon, which has moved up into the
    /// hero. Figma sets the headline at the same height in both designs.
    private var contentColumn: some View {
        VStack(spacing: 0) {
            // The break is explicit so the headline always sets in the two
            // lines the design calls for, at any text width.
            Text("Swipe right on\nyour next job.")
                .font(ReziFont.headline)
                .tracking(ReziFont.headlineTracking)
                .foregroundStyle(ReziColor.headline)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: Metrics.copyWidth)
                .entrance(appeared, delay: Motion.Beat.headline, offsetY: 20, startBlur: 4)

            gap(Metrics.headlineToSubhead)

            Text("Every job scored against your resume. Skip the bad fits, apply to the rest in a tap.")
                .font(ReziFont.subhead)
                .tracking(ReziFont.subheadTracking)
                .lineSpacing(ReziFont.subheadLineSpacing)
                .foregroundStyle(ReziColor.subhead)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: Metrics.copyWidth)
                .entrance(appeared, delay: Motion.Beat.subhead, offsetY: 18)

            gap(Metrics.subheadToStats)

            StatsPanel(
                appeared: appeared,
                buttonTitle: "Get Started",
                buttonAction: onGetStarted,
                buttonColor: ReziColor.Marquee.accent,
                buttonPressedColor: ReziColor.Marquee.accentPressed
            )

            gap(Metrics.panelToSignIn)

            signInRow
                .entrance(appeared, delay: Motion.Beat.signIn, offsetY: 12)
        }
    }

    private var signInRow: some View {
        HStack(spacing: 5) {
            Text("Already an account?")
                .font(ReziFont.footnote)
                .foregroundStyle(ReziColor.signInMuted)

            Button(action: onSignIn) {
                Text("Sign in")
                    .font(ReziFont.footnoteAction)
                    .foregroundStyle(ReziColor.Marquee.accent)
            }
            .buttonStyle(.plain)
        }
    }

    private func gap(_ height: CGFloat) -> some View {
        Color.clear.frame(height: height)
    }
}

/// Where the copy column starts, reported up to the page so the lower rows
/// can be placed from it.
private struct CopyTopKey: PreferenceKey {
    static let defaultValue: CGFloat? = nil

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = nextValue() ?? value
    }
}

#Preview("Marquee onboarding") {
    MarqueeOnboardingView()
}
