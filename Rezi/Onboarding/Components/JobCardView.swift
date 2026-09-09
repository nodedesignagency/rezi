import SwiftUI

/// One job in the deck: logo, title, salary · location, and the match gauge.
///
/// Laid out at the design's 353 × 76 and then scaled as a whole, so every card
/// in the stack stays typographically identical to the front one.
struct JobCardView: View {
    var job: JobCard
    var revealed: Bool
    var isFront: Bool

    var body: some View {
        HStack(spacing: 0) {
            CompanyMark(index: job.logoIndex, size: Metrics.cardLogoSize)

            VStack(alignment: .leading, spacing: Metrics.cardTitleToMeta) {
                Text(job.title)
                    .font(ReziFont.cardTitle)
                    .foregroundStyle(ReziColor.cardTitle)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(job.salary)
                    Rectangle()
                        .fill(ReziColor.cardDivider)
                        .frame(width: 1, height: Metrics.cardMetaDividerHeight)
                    Text(job.location)
                }
                .font(ReziFont.cardMeta)
                .foregroundStyle(ReziColor.cardMeta)
                .lineLimit(1)
            }
            .padding(.leading, Metrics.cardLogoToText)

            Spacer(minLength: 8)

            ScoreGauge(
                score: job.score,
                label: job.scoreLabel,
                color: job.scoreColor,
                revealed: revealed,
                isFront: isFront
            )
        }
        .padding(.leading, Metrics.cardPaddingLeading)
        .padding(.trailing, Metrics.cardPaddingTrailing)
        .frame(width: Metrics.cardWidth, height: Metrics.cardHeight)
        .background(
            RoundedRectangle(cornerRadius: Metrics.cardCornerRadius, style: .continuous)
                .fill(ReziColor.cardSurface)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(job.title), \(job.salary), \(job.location). Match score \(job.score), \(job.scoreLabel)."
        )
    }
}
