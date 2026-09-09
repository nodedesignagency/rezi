import SwiftUI

/// A number that animates through its intermediate values.
///
/// Conforming a `View` to `Animatable` lets SwiftUI interpolate `value` frame
/// by frame, so the label counts rather than snapping.
struct AnimatedNumber: View, Animatable {
    var value: Double
    var decimals: Int
    var suffix: String

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        // Monospaced digits stop the label jittering as the digits change.
        Text(String(format: "%.\(decimals)f", value) + suffix)
            .monospacedDigit()
    }
}

struct OnboardingStat: Identifiable {
    var id: String { label }
    /// Imageset holding the icon from the design.
    let asset: String
    /// Used if that imageset is empty.
    let symbol: String
    let value: Double
    let decimals: Int
    let suffix: String
    let label: String

    static let all: [OnboardingStat] = [
        OnboardingStat(asset: "StatApplications", symbol: "list.clipboard.fill",
                       value: 1.2, decimals: 1, suffix: "M", label: "Applications Sent"),
        OnboardingStat(asset: "StatRating", symbol: "rosette",
                       value: 4.7, decimals: 1, suffix: "", label: "App Store Rating"),
        OnboardingStat(asset: "StatSeekers", symbol: "person.2.fill",
                       value: 4.2, decimals: 1, suffix: "M", label: "Job Seekers")
    ]
}

/// The duotone icon above each stat.
///
/// The supplied SVGs are template images, so their second tone survives as
/// alpha and picks up whatever tint is applied here.
struct StatIcon: View {
    var stat: OnboardingStat
    var size: CGFloat = 20

    var body: some View {
        Group {
            if Artwork.has(stat.asset) {
                Image(stat.asset)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: stat.symbol)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(width: size, height: size)
        .foregroundStyle(ReziColor.statValue)
    }
}

// MARK: - Panel

/// The proof bar and the Get Started button, in one card.
///
/// Figma builds these as a single 353 x 140 frame — 4pt padding, 4pt gap — so
/// the button sits *inside* the panel with the fill showing as a thin ring
/// around it, rather than standing alone below the card.
struct StatsPanel: View {
    var appeared: Bool
    var buttonTitle: String
    var buttonAction: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let stats = OnboardingStat.all

    var body: some View {
        VStack(spacing: Metrics.panelGap) {
            statsRow

            PrimaryButton(title: buttonTitle, action: buttonAction)
                .entrance(appeared, delay: Motion.Beat.button, offsetY: 0, startScale: 0.94)
        }
        .padding(Metrics.panelPadding)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: Metrics.panelTopRadius,
                bottomLeadingRadius: Metrics.panelBottomRadius,
                bottomTrailingRadius: Metrics.panelBottomRadius,
                topTrailingRadius: Metrics.panelTopRadius,
                style: .continuous
            )
            .fill(ReziColor.panelSurface)
        )
        .entrance(appeared, delay: Motion.Beat.stats, offsetY: 24)
    }

    // MARK: Stats row

    private var statsRow: some View {
        HStack(spacing: 0) {
            ForEach(stats.indices, id: \.self) { index in
                let stat = stats[index]

                if index > 0 {
                    divider
                }

                column(stat, index: index)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: Metrics.statsHeight)
        .background(
            RoundedRectangle(cornerRadius: Metrics.statsCornerRadius, style: .continuous)
                .fill(ReziColor.statsSurface.opacity(ReziColor.statsSurfaceOpacity))
        )
    }

    /// A hairline that fades out at both ends rather than stopping flat.
    private var divider: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0), location: 0),
                        .init(color: .black, location: 0.5),
                        .init(color: .black.opacity(0), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: Metrics.statsDividerWidth, height: Metrics.statsDividerHeight)
            .opacity(Metrics.statsDividerOpacity)
    }

    private func column(_ stat: OnboardingStat, index: Int) -> some View {
        let delay = Motion.Beat.stats + Double(index) * Motion.Beat.statStagger

        return VStack(spacing: 4) {
            StatIcon(stat: stat)

            AnimatedNumber(
                value: appeared ? stat.value : 0,
                decimals: stat.decimals,
                suffix: stat.suffix
            )
            .font(ReziFont.statValue)
            .tracking(ReziFont.statValueTracking)
            .foregroundStyle(ReziColor.statValue)
            .animation(countAnimation(delay: delay), value: appeared)

            Text(stat.label)
                .font(ReziFont.statLabel)
                .foregroundStyle(ReziColor.statLabel)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .entrance(appeared, delay: delay, offsetY: 10)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(stat.value.formatted())\(stat.suffix) \(stat.label)"
        )
    }

    /// The count-up. With Reduce Motion on the number is simply already there.
    private func countAnimation(delay: Double) -> Animation? {
        reduceMotion ? nil : .easeOut(duration: 0.9).delay(delay)
    }
}
