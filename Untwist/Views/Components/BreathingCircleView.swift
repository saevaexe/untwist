import SwiftUI

struct BreathingCircleView: View {
    enum Phase: Equatable {
        case inhale, hold, exhale

        var gradient: (Color, Color) {
            switch self {
            case .inhale: (Color(hex: 0x64B5F6), Color(hex: 0x4DD0E1))
            case .hold:   (Color(hex: 0x9575CD), Color(hex: 0x7E57C2))
            case .exhale:  (Color(hex: 0x52C4A0), Color(hex: 0x81C784))
            }
        }
    }

    let phase: Phase
    let circleSize: CGFloat
    let countdown: Int
    let progress: CGFloat
    let scaleTarget: CGFloat
    let scaleDuration: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var ringScales: [CGFloat] = [0.5, 0.5, 0.5, 0.5]

    private var phaseGradient: LinearGradient {
        let (c1, c2) = phase.gradient
        return LinearGradient(colors: [c1, c2], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var phaseColor: Color { phase.gradient.0 }

    var body: some View {
        ZStack {
            // Glow
            if !reduceMotion {
                Circle()
                    .fill(phaseColor.opacity(0.25))
                    .frame(width: circleSize * 1.4, height: circleSize * 1.4)
                    .blur(radius: 40 * ringScales[0])
            }

            // Ripple rings (outermost → innermost)
            if !reduceMotion {
                ForEach((1...3).reversed(), id: \.self) { i in
                    Circle()
                        .fill(phaseGradient)
                        .opacity(rippleOpacity(for: i))
                        .frame(width: circleSize, height: circleSize)
                        .scaleEffect(ringScales[i])
                }
            }

            // Main circle
            Circle()
                .fill(phaseGradient)
                .opacity(0.35)
                .frame(width: circleSize, height: circleSize)
                .scaleEffect(ringScales[0])

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(phaseGradient, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: circleSize + 12, height: circleSize + 12)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.95), value: progress)

            // Label + countdown
            VStack(spacing: 4) {
                Text(phaseLabel)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(Color.textPrimary)

                Text("\(countdown)")
                    .font(.caption.weight(.medium).monospacedDigit())
                    .foregroundStyle(Color.textSecondary)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: countdown)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: phase)
        .onAppear { applyScale() }
        .onChange(of: scaleTarget) { _, _ in applyScale() }
    }

    private func applyScale() {
        let dur = reduceMotion ? 0.3 : scaleDuration
        for i in 0..<4 {
            let delay = reduceMotion ? 0.0 : Double(i) * 0.08
            withAnimation(.easeInOut(duration: dur).delay(delay)) {
                ringScales[i] = scaleTarget
            }
        }
    }

    private var phaseLabel: String {
        switch phase {
        case .inhale: String(localized: "breath_inhale", defaultValue: "Breathe in")
        case .hold:   String(localized: "breath_hold", defaultValue: "Hold")
        case .exhale:  String(localized: "breath_exhale", defaultValue: "Breathe out")
        }
    }

    private func rippleOpacity(for ring: Int) -> Double {
        switch ring {
        case 1: 0.20
        case 2: 0.12
        case 3: 0.06
        default: 0.35
        }
    }

    // MARK: - Haptic

    static func triggerHaptic(for phase: Phase, reduceMotion: Bool) {
        guard !reduceMotion else { return }
        let style: UIImpactFeedbackGenerator.FeedbackStyle = switch phase {
        case .inhale: .light
        case .hold:   .medium
        case .exhale:  .soft
        }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    static func triggerRoundCompleteHaptic(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
}
