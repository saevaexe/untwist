import SwiftUI

struct UnwindingNowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: UnwindPhase = .calming
    @State private var breathCount = 0
    @State private var breathPhase: BreathStep = .inhale
    @State private var circleScale: CGFloat = 0.5
    @State private var showRedirect = false

    enum UnwindPhase {
        case calming, breathing, redirect
    }

    enum BreathStep {
        case inhale, hold, exhale

        var label: String {
            switch self {
            case .inhale: String(localized: "breath_inhale", defaultValue: "Breathe in")
            case .hold: String(localized: "breath_hold", defaultValue: "Hold")
            case .exhale: String(localized: "breath_exhale", defaultValue: "Breathe out")
            }
        }

        var duration: Double { 4 } // 4-4-4 simplified rhythm
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            switch phase {
            case .calming:
                calmingView
            case .breathing:
                breathingView
            case .redirect:
                redirectView
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .onAppear { startCalming() }
    }

    // MARK: - Phase 1: Calming (5 seconds)

    private var calmingView: some View {
        VStack(spacing: 20) {
            TwistyView(mood: .calm, size: 160)

            Text(String(localized: "unwind_calming_title", defaultValue: "Let's slow down together"))
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    // MARK: - Phase 2: Breathing (3 rounds of 4-4-4)

    private var breathingView: some View {
        VStack(spacing: 24) {
            Text(String(localized: "unwind_breathing_round", defaultValue: "Breath \(breathCount + 1) of 3"))
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)

            ZStack {
                Circle()
                    .fill(Color.successGreen.opacity(0.15))
                    .frame(width: 200, height: 200)

                Circle()
                    .fill(Color.successGreen.opacity(0.3))
                    .frame(width: 200, height: 200)
                    .scaleEffect(circleScale)

                Text(breathPhase.label)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(Color.textPrimary)
            }

            Button {
                dismiss()
            } label: {
                Text(String(localized: "unwind_skip", defaultValue: "Skip"))
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }

    // MARK: - Phase 3: Redirect

    private var redirectView: some View {
        VStack(spacing: 24) {
            TwistyView(mood: .celebrating, size: 140)

            Text(String(localized: "unwind_redirect_title", defaultValue: "You're doing great"))
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.textPrimary)

            NavigationLink {
                ThoughtUnwinderView()
            } label: {
                Text(String(localized: "unwind_write_it_down", defaultValue: "Write it down"))
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryPurple)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)

            Button {
                dismiss()
            } label: {
                Text(String(localized: "unwind_im_good", defaultValue: "I'm good for now"))
                    .font(.subheadline)
                    .foregroundStyle(Color.primaryPurple)
            }
        }
    }

    // MARK: - Logic

    private func startCalming() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation { phase = .breathing }
            runBreathCycle()
        }
    }

    private func runBreathCycle() {
        guard phase == .breathing else { return }

        // Inhale
        breathPhase = .inhale
        let animDuration = reduceMotion ? 0.3 : 4.0
        withAnimation(.easeInOut(duration: animDuration)) {
            circleScale = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            guard phase == .breathing else { return }

            // Hold
            breathPhase = .hold

            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                guard phase == .breathing else { return }

                // Exhale
                breathPhase = .exhale
                let exhaleDuration = reduceMotion ? 0.3 : 4.0
                withAnimation(.easeInOut(duration: exhaleDuration)) {
                    circleScale = 0.5
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    guard phase == .breathing else { return }

                    breathCount += 1
                    if breathCount >= 3 {
                        withAnimation { phase = .redirect }
                    } else {
                        runBreathCycle()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        UnwindingNowView()
    }
}
