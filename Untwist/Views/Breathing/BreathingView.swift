import SwiftUI
import SwiftData

struct BreathingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("rc_first_breathing") private var hasTrackedFirstBreathing = false
    @State private var isActive = false
    @State private var phase: BreathPhase = .inhale
    @State private var currentRound = 1
    @State private var totalRounds = 5
    @State private var scaleTarget: CGFloat = 0.5
    @State private var countdown: Int = 4
    @State private var progress: CGFloat = 1.0
    @State private var countdownTimer: Timer?
    @State private var startTime: Date?
    @State private var completed = false

    enum BreathPhase: String {
        case inhale, hold, exhale

        var duration: Double {
            switch self {
            case .inhale: 4
            case .hold: 7
            case .exhale: 8
            }
        }

        var label: String {
            switch self {
            case .inhale: String(localized: "breath_inhale", defaultValue: "Breathe in")
            case .hold: String(localized: "breath_hold", defaultValue: "Hold")
            case .exhale: String(localized: "breath_exhale", defaultValue: "Breathe out")
            }
        }
    }

    var body: some View {
        ZStack {
            AppScreenBackground(
                primaryTint: Color.successGreen.opacity(0.18),
                secondaryTint: Color.primaryPurple.opacity(0.14),
                tertiaryTint: Color.twistyOrange.opacity(0.12)
            )

            VStack(spacing: 16) {
                headerCard
                Spacer(minLength: 0)

                if completed {
                    completedView
                } else if isActive {
                    activeView
                } else {
                    startView
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 26)
        }
        .navigationTitle(String(localized: "breathing_title", defaultValue: "Breathing Exercise"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Start

    private var startView: some View {
        VStack(spacing: 24) {
            TwistyView(mood: .breathing, size: 200)

            Text(String(localized: "breathing_description", defaultValue: "4-7-8 Breathing Technique"))
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.textPrimary)

            Text(String(localized: "breathing_instruction", defaultValue: "Breathe in for 4 seconds, hold for 7, breathe out for 8. Simple and calming."))
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Button {
                startBreathing()
            } label: {
                Text(String(localized: "breathing_start", defaultValue: "Start"))
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.successGreen, Color.primaryPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .shadow(color: Color.successGreen.opacity(0.18), radius: 10, y: 4)
        }
        .padding(24)
        .elevatedCard(stroke: Color.successGreen.opacity(0.25), shadowColor: Color.successGreen.opacity(0.16))
    }

    // MARK: - Active

    private var activeView: some View {
        VStack(spacing: 24) {
            Text(
                String(
                    format: String(localized: "breathing_round", defaultValue: "Round %lld of %lld"),
                    locale: Locale.current,
                    Int64(currentRound),
                    Int64(totalRounds)
                )
            )
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.textSecondary)

            HStack(spacing: 8) {
                ForEach(0..<totalRounds, id: \.self) { index in
                    Capsule(style: .continuous)
                        .fill(index < currentRound ? Color.successGreen : Color.successGreen.opacity(0.18))
                        .frame(width: 24, height: 6)
                }
            }

            BreathingCircleView(
                phase: breathingPhase,
                circleSize: 224,
                countdown: countdown,
                progress: progress,
                scaleTarget: scaleTarget,
                scaleDuration: reduceMotion ? 0.3 : phase.duration
            )

            Button {
                stopBreathing()
                } label: {
                    Text(String(localized: "breathing_stop", defaultValue: "Stop"))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.cardBackground.opacity(0.85))
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color.textSecondary.opacity(0.2), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
        }
        .padding(24)
        .elevatedCard(stroke: Color.successGreen.opacity(0.25), shadowColor: Color.successGreen.opacity(0.16))
        .onAppear { runCycle() }
    }

    // MARK: - Completed

    private var completedView: some View {
        VStack(spacing: 24) {
            TwistyView(mood: .celebrating, size: 200)

            Text(String(localized: "breathing_done", defaultValue: "Well done!"))
                .font(.title.weight(.semibold))
                .foregroundStyle(Color.textPrimary)

            Text(String(localized: "breathing_done_message", defaultValue: "You completed \(totalRounds) rounds of breathing."))
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)

            Button {
                dismiss()
            } label: {
                Text(String(localized: "breathing_close", defaultValue: "Done"))
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.primaryPurple, Color.secondaryLavender],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .shadow(color: Color.primaryPurple.opacity(0.16), radius: 10, y: 4)
        }
        .padding(24)
        .elevatedCard(stroke: Color.primaryPurple.opacity(0.20), shadowColor: Color.primaryPurple.opacity(0.14))
    }

    private var headerCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "breathing_header_title", defaultValue: "Calm your body"))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(String(localized: "breathing_header_sub", defaultValue: "4-7-8 rhythm for a quick reset"))
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Image(systemName: "wind")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.successGreen)
                .frame(width: 42, height: 42)
                .background(Color.successGreen.opacity(0.14), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(16)
        .elevatedCard(stroke: Color.successGreen.opacity(0.18), shadowColor: .black.opacity(0.07))
    }

    private var breathingPhase: BreathingCircleView.Phase {
        switch phase {
        case .inhale: .inhale
        case .hold: .hold
        case .exhale: .exhale
        }
    }

    // MARK: - Breathing Logic

    private func startBreathing() {
        isActive = true
        currentRound = 1
        startTime = Date()
    }

    private func stopBreathing() {
        isActive = false
        countdownTimer?.invalidate()
        saveSession()
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

    private func runCycle() {
        guard isActive else { return }

        // Inhale
        phase = .inhale
        scaleTarget = 1.0
        startCountdown(seconds: Int(phase.duration))
        BreathingCircleView.triggerHaptic(for: .inhale, reduceMotion: reduceMotion)

        DispatchQueue.main.asyncAfter(deadline: .now() + phase.duration) {
            guard isActive else { return }

            // Hold
            phase = .hold
            startCountdown(seconds: Int(phase.duration))
            BreathingCircleView.triggerHaptic(for: .hold, reduceMotion: reduceMotion)

            DispatchQueue.main.asyncAfter(deadline: .now() + phase.duration) {
                guard isActive else { return }

                // Exhale
                phase = .exhale
                scaleTarget = 0.5
                startCountdown(seconds: Int(phase.duration))
                BreathingCircleView.triggerHaptic(for: .exhale, reduceMotion: reduceMotion)

                DispatchQueue.main.asyncAfter(deadline: .now() + phase.duration) {
                    guard isActive else { return }

                    if currentRound >= totalRounds {
                        BreathingCircleView.triggerRoundCompleteHaptic(reduceMotion: reduceMotion)
                        countdownTimer?.invalidate()
                        isActive = false
                        completed = true
                        saveSession()
                    } else {
                        BreathingCircleView.triggerRoundCompleteHaptic(reduceMotion: reduceMotion)
                        currentRound += 1
                        runCycle()
                    }
                }
            }
        }
    }

    private func saveSession() {
        guard let start = startTime else { return }
        let duration = Date().timeIntervalSince(start)
        let session = BreathingSession(rounds: currentRound, duration: duration)
        modelContext.insert(session)

        if !hasTrackedFirstBreathing {
            AnalyticsManager.trackMilestone(.firstBreathingSession)
            hasTrackedFirstBreathing = true
        }
    }
}

#Preview {
    NavigationStack {
        BreathingView()
    }
    .modelContainer(for: BreathingSession.self, inMemory: true)
}
