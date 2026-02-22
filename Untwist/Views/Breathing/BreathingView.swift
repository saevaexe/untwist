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
        VStack(spacing: 32) {
            Spacer()

            if completed {
                completedView
            } else if isActive {
                activeView
            } else {
                startView
            }

            Spacer()
        }
        .background(Color.appBackground)
        .navigationTitle(String(localized: "breathing_title", defaultValue: "Breathing Exercise"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Start

    private var startView: some View {
        VStack(spacing: 24) {
            Image(systemName: "wind")
                .font(.system(size: 60))
                .foregroundStyle(Color.successGreen)

            Text(String(localized: "breathing_description", defaultValue: "4-7-8 Breathing Technique"))
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.textPrimary)

            Text(String(localized: "breathing_instruction", defaultValue: "Breathe in for 4 seconds, hold for 7, breathe out for 8. Simple and calming."))
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                startBreathing()
            } label: {
                Text(String(localized: "breathing_start", defaultValue: "Start"))
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.successGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)
        }
    }

    // MARK: - Active

    private var activeView: some View {
        VStack(spacing: 24) {
            Text("Round \(currentRound) of \(totalRounds)")
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

                Text(phase.label)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(Color.textPrimary)
            }

            Button {
                stopBreathing()
            } label: {
                Text(String(localized: "breathing_stop", defaultValue: "Stop"))
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .onAppear { runCycle() }
    }

    // MARK: - Completed

    private var completedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.successGreen)

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
                    .background(Color.primaryPurple)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)
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
