import SwiftUI

/// The onboarding screen.
///
/// Layout follows the Figma frame: a hero zone holding the clay phone and the
/// card stack, positioned by ratio from the top of the screen, and a content
/// column anchored to the bottom safe area.
///
/// A single `appeared` flag drives the whole entrance — each element carries
/// its own delay from `Motion.Beat`, so the sequence is described in one place
/// rather than spread across nested animation blocks.
struct OnboardingView: View {
    var onGetStarted: () -> Void = {}
    var onSignIn: () -> Void = {}

    @StateObject private var model = OnboardingModel()
    @State private var appeared = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .top) {
            SkyBackground(appeared: appeared)

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
        .sensoryFeedback(.impact(weight: .light), trigger: model.userSwipeCount)
        .task {
            // Let the pre-animation state render for a frame, so the springs
            // have something to travel from.
            guard !appeared else { return }
            try? await Task.sleep(for: Motion.entranceLeadIn)
            appeared = true
        }
        .task(id: model.autoplayTick) {
            await runAutoplay()
        }
    }

    // MARK: - Hero

    /// Phone, clouds and cards, sized off the screen width and positioned off
    /// its height so the composition holds its proportions on any device.
    ///
    /// The order matters and matches Figma: clouds after the device, so the
    /// phone sinks into them rather than sitting on top with a hard
    /// rectangular edge; then the white veil, which dissolves whatever edge is
    /// left into the page; then the cards, above everything.
    private func hero(in size: CGSize) -> some View {
        let scale = Metrics.heroScale(for: size.width)
        let vScale = size.height / Metrics.designHeight

        return ZStack(alignment: .top) {
            PhoneMockup()
                .frame(
                    width: Metrics.phoneWidth * scale,
                    height: Metrics.phoneHeight * scale
                )
                .offset(y: Metrics.phoneTop * vScale)
                .entrance(appeared, delay: Motion.Beat.phone, offsetY: 44, startScale: 0.94)

            CloudLayer(appeared: appeared, size: size)

            // Above the clouds, not below: under them the phone's edge still
            // shows through wherever the cloud is thin.
            WhiteVeil(appeared: appeared, size: size)

            JobCardStack(model: model, appeared: appeared)
                .scaleEffect(scale, anchor: .top)
                .offset(y: Metrics.cardTop * vScale)
        }
        .frame(width: size.width, height: size.height, alignment: .top)
    }

    // MARK: - Content

    private var contentColumn: some View {
        VStack(spacing: 0) {
            AppIconBadge(appeared: appeared)

            gap(Metrics.iconToHeadline)

            // The break is explicit so the headline always sets in the two
            // lines the design calls for, at any text width.
            Text("Swipe right on\nyour next job.")
                .font(ReziFont.headline)
                .foregroundStyle(ReziColor.headline)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .entrance(appeared, delay: Motion.Beat.headline, offsetY: 20, startBlur: 4)

            gap(Metrics.headlineToSubhead)

            Text("Every job scored against your resume. Skip the bad fits, apply to the rest in a tap.")
                .font(ReziFont.subhead)
                .foregroundStyle(ReziColor.subhead)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .entrance(appeared, delay: Motion.Beat.subhead, offsetY: 18)

            gap(Metrics.subheadToStats)

            StatsPanel(
                appeared: appeared,
                buttonTitle: "Get Started",
                buttonAction: onGetStarted
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
                    .foregroundStyle(ReziColor.accent)
            }
            .buttonStyle(.plain)
        }
    }

    private func gap(_ height: CGFloat) -> some View {
        Color.clear.frame(height: height)
    }

    // MARK: - Autoplay

    /// Cycles the deck on its own so the screen demonstrates itself.
    ///
    /// Committing a swipe bumps `autoplayTick`, which cancels this task and
    /// starts a fresh one — that is what resets the clock after a manual
    /// swipe, so a card the user just threw is not immediately followed by an
    /// automatic one.
    @MainActor
    private func runAutoplay() async {
        guard !reduceMotion else { return }

        var interval = model.autoplayTick == 0
            ? Motion.autoplayFirstInterval
            : Motion.autoplayInterval

        while !Task.isCancelled {
            try? await Task.sleep(for: interval)
            interval = Motion.autoplayInterval

            if Task.isCancelled { return }
            guard !model.isDragging else { continue }

            model.commit(.right, reduceMotion: reduceMotion)
        }
    }
}

#Preview("Onboarding") {
    OnboardingView()
}
