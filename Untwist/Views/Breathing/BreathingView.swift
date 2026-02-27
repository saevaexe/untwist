import SwiftUI
import SwiftData

struct BreathingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isActive = false
    @State private var phase: BreathPhase = .inhale
    @State private var currentRound = 1
    @State private var totalRounds = 5
    @State private var circleScale: CGFloat = 0.5
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

            ZStack {
                Circle()
                    .fill(Color.successGreen.opacity(0.15))
                    .frame(width: 224, height: 224)

                Circle()
                    .fill(Color.successGreen.opacity(0.3))
                    .frame(width: 224, height: 224)
                    .scaleEffect(circleScale)

                Circle()
                    .stroke(Color.successGreen.opacity(0.35), lineWidth: 1)
                    .frame(width: 224, height: 224)
                    .scaleEffect(circleScale * 0.74)

                Text(phase.label)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(Color.textPrimary)
            }

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

    // MARK: - Breathing Logic

    private func startBreathing() {
        isActive = true
        currentRound = 1
        startTime = Date()
    }

    private func stopBreathing() {
        isActive = false
        saveSession()
    }

    private func runCycle() {
        guard isActive else { return }

        // Inhale
        phase = .inhale
        let animDuration = reduceMotion ? 0.3 : phase.duration
        withAnimation(.easeInOut(duration: animDuration)) {
            circleScale = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + phase.duration) {
            guard isActive else { return }

            // Hold
            phase = .hold

            DispatchQueue.main.asyncAfter(deadline: .now() + phase.duration) {
                guard isActive else { return }

                // Exhale
                phase = .exhale
                let exhaleDuration = reduceMotion ? 0.3 : phase.duration
                withAnimation(.easeInOut(duration: exhaleDuration)) {
                    circleScale = 0.5
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + phase.duration) {
                    guard isActive else { return }

                    if currentRound >= totalRounds {
                        isActive = false
                        completed = true
                        saveSession()
                    } else {
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
    }
}

#Preview {
    NavigationStack {
        BreathingView()
    }
    .modelContainer(for: BreathingSession.self, inMemory: true)
}
