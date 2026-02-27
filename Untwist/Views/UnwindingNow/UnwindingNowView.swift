import SwiftUI

struct UnwindingNowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: UnwindPhase = .calming
    @State private var breathCount = 0
    @State private var breathPhase: BreathStep = .inhale
    @State private var scaleTarget: CGFloat = 0.56
    @State private var countdown: Int = 4
    @State private var progress: CGFloat = 1.0
    @State private var countdownTimer: Timer?

    enum UnwindPhase: Int {
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
        ZStack {
            backgroundLayer

            VStack(spacing: 14) {
                topBar
                phaseProgress

                Spacer(minLength: 0)

                contentCard

                Spacer(minLength: 0)

                if phase == .breathing {
                    Button {
                        dismiss()
                    } label: {
                        Text(String(localized: "unwind_skip", defaultValue: "Skip"))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.textSecondary)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 10)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.cardBackground.opacity(0.85))
                            )
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(Color.textSecondary.opacity(0.20), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .onAppear { startCalming() }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appBackground, Color.primaryPurple.opacity(0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.successGreen.opacity(0.22))
                .frame(width: 260, height: 260)
                .blur(radius: 60)
                .offset(x: -150, y: -260)

            Circle()
                .fill(Color.twistyOrange.opacity(0.20))
                .frame(width: 300, height: 300)
                .blur(radius: 70)
                .offset(x: 180, y: -120)
        }
        .ignoresSafeArea()
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "home_unwinding_now", defaultValue: "Unwinding Now"))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(String(localized: "unwind_top_subtitle", defaultValue: "Take one gentle step at a time"))
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.textSecondary)
                    .frame(width: 34, height: 34)
                    .background(Color.cardBackground.opacity(0.85), in: Circle())
            }
        }
    }

    private var phaseProgress: some View {
        HStack(spacing: 8) {
            phasePill(label: String(localized: "unwind_phase_settle", defaultValue: "Settle"), isActive: phase == .calming)
            phasePill(label: String(localized: "unwind_phase_breathe", defaultValue: "Breathe"), isActive: phase == .breathing)
            phasePill(label: String(localized: "unwind_phase_next", defaultValue: "Next Step"), isActive: phase == .redirect)
        }
    }

    private func phasePill(label: String, isActive: Bool) -> some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .foregroundStyle(isActive ? Color.cardBackground : Color.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity)
            .background(
                Capsule(style: .continuous)
                    .fill(isActive ? Color.primaryPurple : Color.cardBackground.opacity(0.82))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(isActive ? Color.clear : Color.textSecondary.opacity(0.15), lineWidth: 1)
            )
    }

    private var contentCard: some View {
        VStack(spacing: 16) {
            switch phase {
            case .calming:
                calmingView
            case .breathing:
                breathingView
            case .redirect:
                redirectView
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 18)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.cardBackground.opacity(0.94))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.primaryPurple.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 14, y: 6)
        .animation(.spring(response: 0.42, dampingFraction: 0.84), value: phase)
    }

    private var calmingView: some View {
        VStack(spacing: 12) {
            TwistyView(mood: .calm, size: 200)

            Text(String(localized: "unwind_calming_title", defaultValue: "Let's slow down together"))
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 14)

            Text(String(localized: "unwind_calming_sub", defaultValue: "You're safe. We'll move gently, one breath at a time."))
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 14)
        }
    }

    private var breathingView: some View {
        VStack(spacing: 18) {
            Text(
                String(
                    format: String(localized: "unwind_breathing_round", defaultValue: "Breath %lld of 3"),
                    locale: Locale.current,
                    Int64(breathCount + 1)
                )
            )
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.textSecondary)

            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule(style: .continuous)
                        .fill(index < breathCount ? Color.successGreen : Color.successGreen.opacity(0.20))
                        .frame(width: 28, height: 5)
                }
            }

            BreathingCircleView(
                phase: breathingCirclePhase,
                circleSize: 196,
                countdown: countdown,
                progress: progress,
                scaleTarget: scaleTarget,
                scaleDuration: reduceMotion ? 0.3 : 4.0
            )
        }
    }

    private var redirectView: some View {
        VStack(spacing: 18) {
            TwistyView(mood: .celebrating, size: 200)

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
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.primaryPurple, Color.secondaryLavender],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button {
                dismiss()
            } label: {
                Text(String(localized: "unwind_im_good", defaultValue: "I'm good for now"))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.primaryPurple)
            }
        }
    }

    private var breathingCirclePhase: BreathingCircleView.Phase {
        switch breathPhase {
        case .inhale: .inhale
        case .hold: .hold
        case .exhale: .exhale
        }
    }

    private func startCountdown(seconds: Int) {
        countdown = seconds
        progress = 1.0
        let total = Double(seconds)
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdown > 1 {
                countdown -= 1
                withAnimation { progress = CGFloat(countdown - 1) / CGFloat(total) }
            } else {
                countdownTimer?.invalidate()
                countdown = 0
                withAnimation { progress = 0 }
            }
        }
    }

    private func startCalming() {
        phase = .calming
        breathCount = 0
        breathPhase = .inhale
        scaleTarget = 0.56

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            guard phase == .calming else { return }
            withAnimation { phase = .breathing }
            runBreathCycle()
        }
    }

    private func runBreathCycle() {
        guard phase == .breathing else { return }

        // Inhale
        breathPhase = .inhale
        scaleTarget = 1.0
        startCountdown(seconds: 4)
        BreathingCircleView.triggerHaptic(for: .inhale, reduceMotion: reduceMotion)

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            guard phase == .breathing else { return }

            // Hold
            breathPhase = .hold
            startCountdown(seconds: 4)
            BreathingCircleView.triggerHaptic(for: .hold, reduceMotion: reduceMotion)

            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                guard phase == .breathing else { return }

                // Exhale
                breathPhase = .exhale
                scaleTarget = 0.5
                startCountdown(seconds: 4)
                BreathingCircleView.triggerHaptic(for: .exhale, reduceMotion: reduceMotion)

                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    guard phase == .breathing else { return }

                    breathCount += 1
                    countdownTimer?.invalidate()
                    if breathCount >= 3 {
                        withAnimation { phase = .redirect }
                    } else {
                        BreathingCircleView.triggerRoundCompleteHaptic(reduceMotion: reduceMotion)
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
