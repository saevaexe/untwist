import SwiftUI
import SwiftData

struct ThoughtUnwinderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var step = 0
    @State private var event = ""
    @State private var automaticThought = ""
    @State private var moodBefore: Double = 50
    @State private var selectedTraps: Set<ThoughtTrapType> = []
    @State private var alternativeThought = ""
    @State private var moodAfter: Double = 50
    @State private var suggestions: [TrapSuggestion] = []
    @State private var showCrisis = false

    var body: some View {
        ZStack {
            AppScreenBackground(
                primaryTint: Color.primaryPurple.opacity(0.16),
                secondaryTint: Color.secondaryLavender.opacity(0.20),
                tertiaryTint: Color.successGreen.opacity(0.10)
            )

            VStack(spacing: 12) {
                progressHeader

                TabView(selection: $step) {
                    stepEvent.tag(0)
                    stepThought.tag(1)
                    stepTraps.tag(2)
                    stepAlternative.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: step)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 18)
        }
        .navigationTitle(String(localized: "unwinder_title", defaultValue: "Thought Unwinder"))
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showCrisis) {
            CrisisView()
        }
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(String(localized: "unwinder_header_title", defaultValue: "Untwist in 4 steps"))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                Text(
                    String(
                        format: String(localized: "unwinder_step_counter", defaultValue: "%lld / 4"),
                        locale: Locale.current,
                        Int64(step + 1)
                    )
                )
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.primaryPurple)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.primaryPurple.opacity(0.12), in: Capsule(style: .continuous))
            }

            ProgressView(value: Double(step + 1), total: 4)
                .tint(Color.primaryPurple)

            Text(stepHint)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(16)
        .elevatedCard(stroke: Color.primaryPurple.opacity(0.16), shadowColor: .black.opacity(0.07))
    }

    private var stepHint: String {
        switch step {
        case 0:
            return String(localized: "unwinder_hint_event", defaultValue: "Start with what happened.")
        case 1:
            return String(localized: "unwinder_hint_thought", defaultValue: "Capture the automatic thought.")
        case 2:
            return String(localized: "unwinder_hint_traps", defaultValue: "Select possible thought traps.")
        default:
            return String(localized: "unwinder_hint_reframe", defaultValue: "Write a gentler alternative thought.")
        }
    }

    // MARK: - Step 1

    private var stepEvent: some View {
        VStack(spacing: 16) {
            TwistyView(mood: .thinking, size: 100, animated: false)

            Text(String(localized: "unwinder_step1_title", defaultValue: "What happened?"))
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.textPrimary)

            Text(String(localized: "unwinder_step1_subtitle", defaultValue: "Describe the situation briefly."))
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)

            styledInputField(
                placeholder: String(localized: "unwinder_event_placeholder", defaultValue: "e.g., My friend didn't reply to my message"),
                text: $event
            )

            Spacer(minLength: 0)

            nextButton(
                enabled: !event.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                crisisCheck: { ThoughtTrapEngine.detectCrisis(event) }
            )
        }
        .padding(22)
        .elevatedCard(stroke: Color.primaryPurple.opacity(0.18), shadowColor: Color.primaryPurple.opacity(0.10))
    }

    // MARK: - Step 2

    private var stepThought: some View {
        VStack(spacing: 16) {
            TwistyView(mood: .thinking, size: 100, animated: false)

            Text(String(localized: "unwinder_step2_title", defaultValue: "What went through your mind?"))
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.textPrimary)

            styledInputField(
                placeholder: String(localized: "unwinder_thought_placeholder", defaultValue: "e.g., They must be angry at me"),
                text: $automaticThought
            )

            VStack(spacing: 8) {
                Text(String(localized: "unwinder_mood_before", defaultValue: "How does this make you feel? (\(Int(moodBefore)))"))
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)

                Slider(value: $moodBefore, in: 0...100, step: 1)
                    .tint(Color.primaryPurple)
            }

            Spacer(minLength: 0)

            nextButton(
                enabled: !automaticThought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                action: { suggestions = ThoughtTrapEngine.analyze(automaticThought) },
                crisisCheck: { ThoughtTrapEngine.detectCrisis(automaticThought) }
            )
        }
        .padding(22)
        .elevatedCard(stroke: Color.secondaryLavender.opacity(0.26), shadowColor: .black.opacity(0.08))
    }

    // MARK: - Step 3

    private var stepTraps: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                Text(String(localized: "unwinder_step3_title", defaultValue: "Any thought traps?"))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)

                if !suggestions.isEmpty {
                    Text(String(localized: "unwinder_suggestions", defaultValue: "We noticed some patterns that might apply:"))
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                }

                ForEach(ThoughtTrapType.allCases) { trap in
                    let isSuggested = suggestions.contains { $0.trap == trap }
                    Button {
                        if selectedTraps.contains(trap) {
                            selectedTraps.remove(trap)
                        } else {
                            selectedTraps.insert(trap)
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(trap.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Color.textPrimary)
                                if isSuggested {
                                    Text(String(localized: "unwinder_might_apply", defaultValue: "Might apply"))
                                        .font(.caption)
                                        .foregroundStyle(Color.primaryPurple)
                                }
                            }
                            Spacer()
                            Image(systemName: selectedTraps.contains(trap) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedTraps.contains(trap) ? Color.primaryPurple : Color.textSecondary)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.appBackground.opacity(0.92))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(
                                    selectedTraps.contains(trap) ? Color.primaryPurple.opacity(0.30) :
                                        (isSuggested ? Color.primaryPurple.opacity(0.20) : Color.clear),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }

                nextButton(enabled: true)
            }
            .padding(20)
        }
        .elevatedCard(stroke: Color.primaryPurple.opacity(0.18), shadowColor: .black.opacity(0.08))
    }

    // MARK: - Step 4

    private var stepAlternative: some View {
        VStack(spacing: 16) {
            TwistyView(mood: .celebrating, size: 100, animated: false)

            Text(String(localized: "unwinder_step4_title", defaultValue: "What's another way to see this?"))
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.textPrimary)

            styledInputField(
                placeholder: String(localized: "unwinder_alternative_placeholder", defaultValue: "e.g., Maybe they're just busy"),
                text: $alternativeThought
            )

            VStack(spacing: 8) {
                Text(String(localized: "unwinder_mood_after", defaultValue: "How do you feel now? (\(Int(moodAfter)))"))
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)

                Slider(value: $moodAfter, in: 0...100, step: 1)
                    .tint(Color.primaryPurple)
            }

            Spacer(minLength: 0)

            Button {
                saveRecord()
            } label: {
                Text(String(localized: "unwinder_save", defaultValue: "Save & Finish"))
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
            .disabled(alternativeThought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(alternativeThought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
        }
        .padding(22)
        .elevatedCard(stroke: Color.secondaryLavender.opacity(0.26), shadowColor: .black.opacity(0.08))
    }

    // MARK: - Helpers

    private func styledInputField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text, axis: .vertical)
            .lineLimit(3...7)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.appBackground.opacity(0.92))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.primaryPurple.opacity(0.14), lineWidth: 1)
            )
    }

    private func nextButton(enabled: Bool, action: (() -> Void)? = nil, crisisCheck: (() -> Bool)? = nil) -> some View {
        Button {
            if let check = crisisCheck, check() {
                showCrisis = true
                return
            }
            action?()
            withAnimation { step += 1 }
        } label: {
            Text(String(localized: "unwinder_next", defaultValue: "Next"))
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    enabled ?
                        LinearGradient(
                            colors: [Color.primaryPurple, Color.secondaryLavender],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!enabled)
    }

    private func saveRecord() {
        let record = ThoughtRecord(
            event: event,
            automaticThought: automaticThought,
            moodBefore: Int(moodBefore),
            moodAfter: Int(moodAfter),
            selectedTraps: Array(selectedTraps),
            alternativeThought: alternativeThought
        )
        modelContext.insert(record)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ThoughtUnwinderView()
    }
    .modelContainer(for: ThoughtRecord.self, inMemory: true)
}
