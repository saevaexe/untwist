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
        VStack {
            // Progress indicator
            ProgressView(value: Double(step + 1), total: 4)
                .tint(Color.primaryPurple)
                .padding(.horizontal)

            TabView(selection: $step) {
                stepEvent.tag(0)
                stepThought.tag(1)
                stepTraps.tag(2)
                stepAlternative.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: step)
        }
        .background(Color.appBackground)
        .navigationTitle(String(localized: "unwinder_title", defaultValue: "Thought Unwinder"))
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showCrisis) {
            CrisisView()
        }
    }

    // MARK: - Step 1: Event

    private var stepEvent: some View {
        VStack(spacing: 20) {
            Spacer()
            TwistyView(mood: .thinking, size: 100, animated: false)
            Text(String(localized: "unwinder_step1_title", defaultValue: "What happened?"))
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.textPrimary)

            Text(String(localized: "unwinder_step1_subtitle", defaultValue: "Describe the situation briefly."))
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)

            TextField(String(localized: "unwinder_event_placeholder", defaultValue: "e.g., My friend didn't reply to my message"), text: $event, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
                .padding(.horizontal)

            Spacer()
            nextButton(enabled: !event.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, crisisCheck: {
                ThoughtTrapEngine.detectCrisis(event)
            })
        }
    }

    // MARK: - Step 2: Thought + Mood Before

    private var stepThought: some View {
        VStack(spacing: 20) {
            Spacer()
            TwistyView(mood: .thinking, size: 100, animated: false)
            Text(String(localized: "unwinder_step2_title", defaultValue: "What went through your mind?"))
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.textPrimary)

            TextField(String(localized: "unwinder_thought_placeholder", defaultValue: "e.g., They must be angry at me"), text: $automaticThought, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
                .padding(.horizontal)

            VStack(spacing: 8) {
                Text(String(localized: "unwinder_mood_before", defaultValue: "How does this make you feel? (\(Int(moodBefore)))"))
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)

                Slider(value: $moodBefore, in: 0...100, step: 1)
                    .tint(Color.primaryPurple)
                    .padding(.horizontal, 32)
            }

            Spacer()
            nextButton(enabled: !automaticThought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, action: {
                suggestions = ThoughtTrapEngine.analyze(automaticThought)
            }, crisisCheck: {
                ThoughtTrapEngine.detectCrisis(automaticThought)
            })
        }
    }

    // MARK: - Step 3: Trap Selection

    private var stepTraps: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(String(localized: "unwinder_step3_title", defaultValue: "Any thought traps?"))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .padding(.top, 20)

                if !suggestions.isEmpty {
                    Text(String(localized: "unwinder_suggestions", defaultValue: "We noticed some patterns that might apply:"))
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                        .padding(.horizontal)
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
                            VStack(alignment: .leading, spacing: 2) {
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
                        .padding()
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSuggested ? Color.primaryPurple.opacity(0.3) : .clear, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                }

                nextButton(enabled: true)
                    .padding(.bottom, 100)
            }
        }
    }

    // MARK: - Step 4: Alternative Thought + Mood After

    private var stepAlternative: some View {
        VStack(spacing: 20) {
            Spacer()
            TwistyView(mood: .celebrating, size: 100, animated: false)
            Text(String(localized: "unwinder_step4_title", defaultValue: "What's another way to see this?"))
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.textPrimary)

            TextField(String(localized: "unwinder_alternative_placeholder", defaultValue: "e.g., Maybe they're just busy"), text: $alternativeThought, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
                .padding(.horizontal)

            VStack(spacing: 8) {
                Text(String(localized: "unwinder_mood_after", defaultValue: "How do you feel now? (\(Int(moodAfter)))"))
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)

                Slider(value: $moodAfter, in: 0...100, step: 1)
                    .tint(Color.primaryPurple)
                    .padding(.horizontal, 32)
            }

            Spacer()

            Button {
                saveRecord()
            } label: {
                Text(String(localized: "unwinder_save", defaultValue: "Save & Finish"))
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryPurple)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)
            .disabled(alternativeThought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(alternativeThought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Helpers

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
                .background(enabled ? Color.primaryPurple : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!enabled)
        .padding(.horizontal)
        .padding(.bottom, 100)
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
