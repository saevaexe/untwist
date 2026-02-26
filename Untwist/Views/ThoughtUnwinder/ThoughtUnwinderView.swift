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
    @State private var showTip = false
    @State private var showCompletion = false
    @FocusState private var isTextFieldFocused: Bool

    @State private var placeholderSet = PlaceholderSet.all[0]

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
        .onTapGesture {
            isTextFieldFocused = false
        }
        .navigationTitle(String(localized: "unwinder_title", defaultValue: "Thought Unwinder"))
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showCrisis) {
            CrisisView()
        }
        .onAppear {
            let sets = PlaceholderSet.all
            let lastIndex = UserDefaults.standard.integer(forKey: "lastPlaceholderIndex")
            let nextIndex = (lastIndex + 1) % sets.count
            UserDefaults.standard.set(nextIndex, forKey: "lastPlaceholderIndex")
            placeholderSet = sets[nextIndex]
        }
        .onChange(of: step) {
            isTextFieldFocused = false
        }
        .sheet(isPresented: $showTip) {
            unwinderTipSheet
        }
        .sheet(isPresented: $showCompletion) {
            ThoughtResolverCompletionView(
                moodBefore: Int(moodBefore),
                moodAfter: Int(moodAfter),
                selectedTraps: Array(selectedTraps),
                onDismiss: { dismiss() }
            )
            .interactiveDismissDisabled()
            .presentationDetents([.large])
        }
    }

    private var unwinderTipSheet: some View {
        NavigationStack {
            ZStack {
                AppScreenBackground(
                    primaryTint: Color.primaryPurple.opacity(0.14),
                    secondaryTint: Color.secondaryLavender.opacity(0.16),
                    tertiaryTint: Color.twistyOrange.opacity(0.08)
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        TwistyView(mood: .reading, size: 72, animated: false)
                            .padding(.top, 4)

                        Text(String(localized: "tip_intro", defaultValue: "The Thought Unwinder helps you step back from overwhelming thoughts and see them from a new angle."))
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)

                        tipItem(
                            step: "1",
                            title: String(localized: "tip_step1_title", defaultValue: "What happened?"),
                            detail: String(localized: "tip_step1_detail", defaultValue: "Write down the situation that triggered your feelings. Keep it brief and factual — just the event, not your interpretation."),
                            color: .primaryPurple
                        )

                        tipItem(
                            step: "2",
                            title: String(localized: "tip_step2_title", defaultValue: "Automatic thought"),
                            detail: String(localized: "tip_step2_detail", defaultValue: "What popped into your mind? These are the instant, often negative thoughts that feel true in the moment. The mood slider captures how this thought makes you feel right now."),
                            color: .secondaryLavender
                        )

                        tipItem(
                            step: "3",
                            title: String(localized: "tip_step3_title", defaultValue: "Thought traps"),
                            detail: String(localized: "tip_step3_detail", defaultValue: "Our minds sometimes fall into predictable patterns. Recognizing these patterns is the first step to breaking free from them. You can select more than one."),
                            color: .twistyOrange
                        )

                        tipItem(
                            step: "4",
                            title: String(localized: "tip_step4_title", defaultValue: "Alternative thought"),
                            detail: String(localized: "tip_step4_detail", defaultValue: "Try to find a more balanced way to see the situation. It doesn't have to be positive — just fairer and more realistic. The mood slider helps you see how reframing shifts your feelings."),
                            color: .successGreen
                        )

                        Text(String(localized: "tip_outro", defaultValue: "With practice, this process becomes more natural. You're building a skill, not looking for a perfect answer."))
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(String(localized: "tip_title", defaultValue: "How it works"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "tip_done", defaultValue: "Done")) {
                        showTip = false
                    }
                    .font(.headline)
                    .foregroundStyle(Color.primaryPurple)
                }
            }
        }
        .presentationDetents([.large])
    }

    private func tipItem(step: String, title: String, detail: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(step)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 26, height: 26)
                    .background(color, in: Circle())

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
            }

            Text(detail)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .elevatedCard(stroke: color.opacity(0.16), shadowColor: .black.opacity(0.06))
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(String(localized: "unwinder_header_title", defaultValue: "Untwist in 4 steps"))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)

                Button {
                    showTip = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.subheadline)
                        .foregroundStyle(Color.primaryPurple)
                }

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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                TwistyView(mood: .thinking, size: 64, animated: false)

                Text(String(localized: "unwinder_step1_title", defaultValue: "What happened?"))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)

                Text(String(localized: "unwinder_step1_subtitle", defaultValue: "Describe the situation briefly."))
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)

                styledInputField(
                    placeholder: placeholderSet.event,
                    text: $event
                )

                nextButton(
                    enabled: !event.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    crisisCheck: { ThoughtTrapEngine.detectCrisis(event) }
                )
            }
            .padding(22)
        }
        .elevatedCard(stroke: Color.primaryPurple.opacity(0.18), shadowColor: Color.primaryPurple.opacity(0.10))
    }

    // MARK: - Step 2

    private var stepThought: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                TwistyView(mood: .thinking, size: 64, animated: false)

                Text(String(localized: "unwinder_step2_title", defaultValue: "What went through your mind?"))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)

                styledInputField(
                    placeholder: placeholderSet.thought,
                    text: $automaticThought
                )

                VStack(spacing: 8) {
                    Text(String(localized: "unwinder_mood_before", defaultValue: "How does this make you feel? (\(Int(moodBefore)))"))
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)

                    Slider(value: $moodBefore, in: 0...100, step: 1)
                        .tint(Color.primaryPurple)

                    Text(String(localized: "unwinder_mood_before_hint", defaultValue: "We'll compare this with how you feel after reframing."))
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary.opacity(0.8))
                        .multilineTextAlignment(.center)
                }

                nextButton(
                    enabled: !automaticThought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    action: { suggestions = ThoughtTrapEngine.analyze(automaticThought) },
                    crisisCheck: { ThoughtTrapEngine.detectCrisis(automaticThought) }
                )
            }
            .padding(22)
        }
        .elevatedCard(stroke: Color.secondaryLavender.opacity(0.26), shadowColor: .black.opacity(0.08))
    }

    // MARK: - Step 3

    private var suggestedTraps: [ThoughtTrapType] {
        suggestions.map(\.trap)
    }

    private var otherTraps: [ThoughtTrapType] {
        ThoughtTrapType.allCases.filter { !suggestedTraps.contains($0) }
    }

    private var stepTraps: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                Text(String(localized: "unwinder_step3_title", defaultValue: "Any thought traps?"))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)

                if !suggestedTraps.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.primaryPurple)
                            Text(String(localized: "unwinder_suggestions_label", defaultValue: "Might apply"))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.primaryPurple)
                        }

                        ForEach(suggestedTraps, id: \.self) { trap in
                            trapSelectionRow(trap, isSuggested: true)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    if !suggestedTraps.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "list.bullet")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.textSecondary)
                            Text(String(localized: "unwinder_all_traps_label", defaultValue: "All thought traps"))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.textSecondary)
                        }
                        .padding(.top, 4)
                    }

                    ForEach(suggestedTraps.isEmpty ? ThoughtTrapType.allCases : otherTraps) { trap in
                        trapSelectionRow(trap, isSuggested: false)
                    }
                }

                nextButton(enabled: true)
            }
            .padding(20)
        }
        .elevatedCard(stroke: Color.primaryPurple.opacity(0.18), shadowColor: .black.opacity(0.08))
    }

    private func trapSelectionRow(_ trap: ThoughtTrapType, isSuggested: Bool) -> some View {
        Button {
            if selectedTraps.contains(trap) {
                selectedTraps.remove(trap)
            } else {
                selectedTraps.insert(trap)
            }
        } label: {
            HStack(spacing: 12) {
                Image(trap.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(trap.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                    Text(trap.description)
                        .font(.caption2)
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Image(systemName: selectedTraps.contains(trap) ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(selectedTraps.contains(trap) ? Color.primaryPurple : Color.textSecondary.opacity(0.5))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(selectedTraps.contains(trap) ? Color.primaryPurple.opacity(0.08) : Color.appBackground.opacity(0.92))
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

    // MARK: - Step 4

    private var stepAlternative: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                TwistyView(mood: .celebrating, size: 64, animated: false)

                Text(String(localized: "unwinder_step4_title", defaultValue: "What's another way to see this?"))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)

                styledInputField(
                    placeholder: placeholderSet.alternative,
                    text: $alternativeThought
                )

                VStack(spacing: 8) {
                    Text(String(localized: "unwinder_mood_after", defaultValue: "How do you feel now? (\(Int(moodAfter)))"))
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)

                    Slider(value: $moodAfter, in: 0...100, step: 1)
                        .tint(Color.primaryPurple)

                    Text(String(localized: "unwinder_mood_after_hint", defaultValue: "See how looking at it differently changed how you feel."))
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary.opacity(0.8))
                        .multilineTextAlignment(.center)
                }

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
        }
        .elevatedCard(stroke: Color.secondaryLavender.opacity(0.26), shadowColor: .black.opacity(0.08))
    }

    // MARK: - Helpers

    private func styledInputField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text, axis: .vertical)
            .focused($isTextFieldFocused)
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
        showCompletion = true
    }
}

private struct PlaceholderSet {
    let event: String
    let thought: String
    let alternative: String

    static let all: [PlaceholderSet] = [
        PlaceholderSet(
            event: String(localized: "unwinder_event_placeholder", defaultValue: "e.g., My friend didn't reply to my message"),
            thought: String(localized: "unwinder_thought_placeholder", defaultValue: "e.g., They must be angry at me"),
            alternative: String(localized: "unwinder_alternative_placeholder", defaultValue: "e.g., Maybe they're just busy")
        ),
        PlaceholderSet(
            event: String(localized: "unwinder_event_placeholder_2", defaultValue: "e.g., I got negative feedback at work"),
            thought: String(localized: "unwinder_thought_placeholder_2", defaultValue: "e.g., I'm not good enough for this job"),
            alternative: String(localized: "unwinder_alternative_placeholder_2", defaultValue: "e.g., One mistake doesn't define my ability")
        ),
        PlaceholderSet(
            event: String(localized: "unwinder_event_placeholder_3", defaultValue: "e.g., I had an argument with my partner"),
            thought: String(localized: "unwinder_thought_placeholder_3", defaultValue: "e.g., This relationship is falling apart"),
            alternative: String(localized: "unwinder_alternative_placeholder_3", defaultValue: "e.g., One argument doesn't mean we can't work it out")
        )
    ]
}

#Preview {
    NavigationStack {
        ThoughtUnwinderView()
    }
    .modelContainer(for: ThoughtRecord.self, inMemory: true)
}
