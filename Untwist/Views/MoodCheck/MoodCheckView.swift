import SwiftUI
import SwiftData

struct MoodCheckView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var score: Double
    @State private var note = ""
    @State private var saved = false
    @State private var showCrisis = false

    init(initialScore: Double = 50) {
        _score = State(initialValue: initialScore)
    }

    var body: some View {
        ZStack {
            AppScreenBackground(
                primaryTint: Color.primaryPurple.opacity(0.15),
                secondaryTint: Color.twistyOrange.opacity(0.18),
                tertiaryTint: Color.successGreen.opacity(0.12)
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    if saved && Int(score) < 60 {
                        savedRedirectView
                    } else {
                        moodInputView
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 120)
            }
        }
        .navigationTitle(String(localized: "mood_check_title", defaultValue: "Mood Check"))
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showCrisis) {
            CrisisView()
        }
    }

    // MARK: - Mood Input

    private var moodInputView: some View {
        VStack(spacing: 16) {
            headerCard

            VStack(spacing: 18) {
                TwistyView(mood: moodTwisty, size: moodTwistySize, animated: false)
                    .frame(width: 240, height: 240)
                    .animation(.easeInOut(duration: 0.3), value: moodTwisty)

                Text("\(Int(score))")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primaryPurple)

                Text(moodLabel)
                    .font(.headline)
                    .foregroundStyle(Color.textSecondary)

                VStack(spacing: 8) {
                    Slider(value: $score, in: 0...100, step: 1)
                        .tint(Color.primaryPurple)

                    HStack {
                        Text(String(localized: "mood_low", defaultValue: "Low"))
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.textSecondary)
                        Spacer()
                        Text(String(localized: "mood_high", defaultValue: "Great"))
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.textSecondary)
                    }
                }
                .padding(.horizontal, 4)
            }
            .padding(20)
            .elevatedCard()

            VStack(alignment: .leading, spacing: 10) {
                Text(String(localized: "mood_note_title", defaultValue: "Quick note (optional)"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)

                TextField(String(localized: "mood_note_placeholder", defaultValue: "Add a note (optional)..."), text: $note, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.appBackground.opacity(0.95))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.primaryPurple.opacity(0.15), lineWidth: 1)
                    )
            }
            .padding(18)
            .elevatedCard(stroke: Color.secondaryLavender.opacity(0.24))

            Button {
                saveMood()
            } label: {
                Text(String(localized: "mood_save", defaultValue: "Save"))
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
            .shadow(color: Color.primaryPurple.opacity(0.18), radius: 10, y: 4)
        }
    }

    // MARK: - Saved + Redirect (mood < 60)

    private var savedRedirectView: some View {
        VStack(spacing: 18) {
            TwistyView(mood: .thinking, size: 200)

            Text(String(localized: "mood_saved", defaultValue: "Mood saved!"))
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.textPrimary)

            Text(String(localized: "mood_redirect_prompt", defaultValue: "Would you like to explore what's on your mind?"))
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            NavigationLink {
                ThoughtUnwinderView()
            } label: {
                Text(String(localized: "mood_redirect_yes", defaultValue: "Explore my thoughts"))
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

            Button {
                dismiss()
            } label: {
                Text(String(localized: "mood_redirect_no", defaultValue: "Not now"))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.primaryPurple)
            }
        }
        .padding(24)
        .elevatedCard(stroke: Color.primaryPurple.opacity(0.2), shadowColor: Color.primaryPurple.opacity(0.14))
    }

    private var headerCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "mood_header_title", defaultValue: "How are you feeling?"))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(String(localized: "mood_header_sub", defaultValue: "Track your current mood in a few seconds"))
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer(minLength: 0)

            Image(systemName: "heart.text.square.fill")
                .font(.title2)
                .foregroundStyle(Color.primaryPurple)
                .frame(width: 42, height: 42)
                .background(Color.primaryPurple.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(16)
        .elevatedCard(stroke: Color.primaryPurple.opacity(0.12), shadowColor: .black.opacity(0.07))
    }

    private var moodTwisty: TwistyMood {
        switch Int(score) {
        case 0..<20: .sad
        case 20..<40: .neutral
        case 40..<60: .calm
        case 60..<80: .happy
        default: .celebrating
        }
    }

    private var moodTwistySize: CGFloat {
        200
    }

    private var moodLabel: String {
        switch Int(score) {
        case 0..<20: String(localized: "mood_very_low", defaultValue: "Very Low")
        case 20..<40: String(localized: "mood_low_label", defaultValue: "Low")
        case 40..<60: String(localized: "mood_neutral", defaultValue: "Neutral")
        case 60..<80: String(localized: "mood_good", defaultValue: "Good")
        default: String(localized: "mood_great", defaultValue: "Great")
        }
    }

    private func saveMood() {
        let entry = MoodEntry(score: Int(score), note: note.isEmpty ? nil : note)
        modelContext.insert(entry)
        saved = true

        // Crisis check on note text
        if !note.isEmpty && ThoughtTrapEngine.detectCrisis(note) {
            showCrisis = true
            return
        }

        // Low mood → show redirect to Thought Unwinder
        if Int(score) < 60 { return }

        dismiss()
    }
}

#Preview {
    NavigationStack {
        MoodCheckView()
    }
    .modelContainer(for: MoodEntry.self, inMemory: true)
}
