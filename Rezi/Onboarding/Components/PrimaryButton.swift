import SwiftUI

/// The Get Started button.
///
/// Springs down under the finger, carries a slow shine that crosses it every
/// few seconds, and fires a haptic on tap.
struct PrimaryButton: View {
    var title: String
    var action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false
    @State private var shine: CGFloat = 0
    @State private var tapCount = 0

    var body: some View {
        Button {
            tapCount += 1
            action()
        } label: {
            Text(title)
                .font(ReziFont.button)
                .foregroundStyle(ReziColor.onAccent)
                .frame(maxWidth: .infinity)
                .frame(height: Metrics.buttonHeight)
                .background(background)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.97 : 1)
        .animation(Motion.buttonPress, value: isPressed)
        .simultaneousGesture(pressGesture)
        .sensoryFeedback(.impact(weight: .medium), trigger: tapCount)
        .onAppear(perform: startShine)
    }

    // MARK: - Background

    private var background: some View {
        let shape = RoundedRectangle(cornerRadius: Metrics.buttonCornerRadius, style: .continuous)

        return shape
            .fill(isPressed ? ReziColor.accentPressed : ReziColor.accent)
            .overlay {
                GeometryReader { geo in
                    shineBar(width: geo.size.width, height: geo.size.height)
                }
            }
            .clipShape(shape)
            .shadow(color: ReziColor.accent.opacity(0.38), radius: 16, x: 0, y: 8)
    }

    /// A slanted highlight that travels across the button. It spends most of
    /// each loop off the edge, which reads as an occasional glint rather than
    /// a constantly moving stripe.
    @ViewBuilder
    private func shineBar(width: CGFloat, height: CGFloat) -> some View {
        if !reduceMotion {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.30),
                            Color.white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width * 0.30, height: height * 2.4)
                .rotationEffect(.degrees(18))
                .offset(x: shine * width * 3.4 - width * 0.8, y: 0)
                .frame(width: width, height: height, alignment: .leading)
        }
    }

    private func startShine() {
        guard !reduceMotion, shine == 0 else { return }
        withAnimation(
            .linear(duration: Motion.buttonShineDuration).repeatForever(autoreverses: false)
        ) {
            shine = 1
        }
    }

    // MARK: - Press tracking

    /// `DragGesture` with no minimum distance gives a press state that tracks
    /// the finger, which `Button`'s own styling does not expose here.
    private var pressGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                if !isPressed { isPressed = true }
            }
            .onEnded { _ in
                isPressed = false
            }
    }
}
