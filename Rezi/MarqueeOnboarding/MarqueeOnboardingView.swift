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
/// Positions follow the Figma frame the same way the first screen's do: sizes
/// scale with the screen's width, heights are placed by ratio from the top, and
/// the content column is anchored to the bottom safe area. As there, a single
/// `appeared` flag drives the entrance.
struct MarqueeOnboardingView: View {
    var onGetStarted: () -> Void = {}
    var onSignIn: () -> Void = {}

    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .top) {
            FlowingGradient(appeared: appeared)

            GeometryReader { geo in
                hero(in: geo.size)
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 0)
                contentColumn
            }
            .padding(.horizontal, Metrics.contentHorizontalPadding)
            .padding(.bottom, 8)
        }
        .background(ReziColor.page.ignoresSafeArea())
        .task {
            // Let the pre-animation state render for a frame, so the springs
            // have something to travel from.
            guard !appeared else { return }
            try? await Task.sleep(for: Motion.entranceLeadIn)
            appeared = true
        }
    }

    // MARK: - Hero

    /// One row of the feed: where it sits, which way it runs, and how fast.
    private struct Lane {
        let cards: [JobCard]
        let direction: SwipeDirection
        let speed: CGFloat
        let top: CGFloat
        let phase: CGFloat
    }

    /// Right, left, right, left: the pair above the icon, then the pair below.
    private static let lanes: [Lane] = JobCard.marqueeRows.indices.map { index in
        Lane(
            cards: JobCard.marqueeRows[index],
            direction: index.isMultiple(of: 2) ? .right : .left,
            speed: Motion.Marquee.rowSpeeds[index],
            top: Metrics.Marquee.rowTops[index],
            phase: Metrics.Marquee.rowPhases[index]
        )
    }

    private func hero(in size: CGSize) -> some View {
        let scale = Metrics.heroScale(for: size.width)
        let vScale = size.height / Metrics.designHeight
        let outerRing = (Metrics.Marquee.ringSizes.last ?? Metrics.Marquee.iconSize) * scale

        // The icon is placed by ratio down the screen. The rows keep their
        // design spacing from it at the cards' own scale, so on a screen
        // shorter than the design's shape they close up around the icon as
        // one group instead of sliding into each other.
        let iconY = Metrics.Marquee.iconCenterY * vScale
        func rowTop(_ designTop: CGFloat) -> CGFloat {
            iconY + (designTop - Metrics.Marquee.iconCenterY) * scale
        }

        return ZStack(alignment: .top) {
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
                .offset(y: rowTop(lane.top))
                // Slides in the way it is about to run.
                .entrance(
                    appeared,
                    delay: Motion.Marquee.Beat.rows + Double(index) * Motion.Marquee.Beat.rowStagger,
                    offsetY: 0,
                    offsetX: -lane.direction.sign * Motion.Marquee.rowEntranceTravel
                )
            }

            IconHalo(appeared: appeared, scale: scale)
                .offset(y: iconY - outerRing / 2)
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

#Preview("Marquee onboarding") {
    MarqueeOnboardingView()
}
