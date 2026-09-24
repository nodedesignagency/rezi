import SwiftUI

@main
struct ReziApp: App {

    init() {
        // Picks up Inter if the font files have been bundled. Everything falls
        // back to SF Pro at the same sizes when they have not.
        InterFont.registerBundledFonts()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Hosts the onboarding screen and gives its two buttons somewhere to go.
///
/// The destination is a deliberate stub — this repo covers the onboarding
/// screen only, so tapping through lands on a placeholder rather than a
/// half-invented sign-up flow.
struct RootView: View {
    /// Which onboarding the app opens on. Both are complete screens; set this
    /// to `.cardStack` to see the first one again.
    private static let design: OnboardingDesign = .marquee

    private enum OnboardingDesign {
        /// `OnboardingView`: one deck of cards over the sky and clouds.
        case cardStack
        /// `MarqueeOnboardingView`: the feed in four rows around the icon.
        case marquee
    }

    @State private var route: Route?

    enum Route: String, Identifiable {
        case getStarted, signIn
        var id: String { rawValue }

        var title: String {
            switch self {
            case .getStarted: return "Get Started"
            case .signIn: return "Sign in"
            }
        }
    }

    var body: some View {
        ZStack {
            onboarding

            if let route {
                PlaceholderScreen(title: route.title) { self.route = nil }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.86), value: route)
    }

    @ViewBuilder
    private var onboarding: some View {
        switch Self.design {
        case .cardStack:
            OnboardingView(
                onGetStarted: { route = .getStarted },
                onSignIn: { route = .signIn }
            )
        case .marquee:
            MarqueeOnboardingView(
                onGetStarted: { route = .getStarted },
                onSignIn: { route = .signIn }
            )
        }
    }
}

private struct PlaceholderScreen: View {
    var title: String
    var onBack: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(ReziColor.headline)

            Text("This is where the \(title.lowercased()) flow goes.")
                .font(ReziFont.subhead)
                .foregroundStyle(ReziColor.subhead)
                .multilineTextAlignment(.center)

            Button("Back to onboarding", action: onBack)
                .font(ReziFont.footnoteAction)
                .foregroundStyle(ReziColor.accent)
                .padding(.top, 6)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ReziColor.page)
    }
}
