import SwiftUI
import SwiftData

struct MoodCheckView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var score: Double = 50
    @State private var note = ""
    @State private var saved = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Mood Twisty — fixed frame prevents layout jumps on mood change
            TwistyView(mood: moodTwisty, size: moodTwistySize, animated: false)
                .frame(width: 160, height: 160)
                .animation(.easeInOut(duration: 0.3), value: moodTwisty)

            // Score display
            Text("\(Int(score))")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(Color.primaryPurple)

            Text(moodLabel)
                .font(.title3)
                .foregroundStyle(Color.textSecondary)

            // Slider
            Slider(value: $score, in: 0...100, step: 1)
                .tint(Color.primaryPurple)
                .padding(.horizontal, 32)

            HStack {
                Text(String(localized: "mood_low", defaultValue: "Low"))
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Text(String(localized: "mood_high", defaultValue: "Great"))
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(.horizontal, 40)

            // Optional note
            TextField(String(localized: "mood_note_placeholder", defaultValue: "Add a note (optional)..."), text: $note, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)
                .padding(.horizontal)

            Spacer()

            // Save button
            Button {
                saveMood()
            } label: {
                Text(String(localized: "mood_save", defaultValue: "Save"))
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryPurple)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
        .background(Color.appBackground)
        .navigationTitle(String(localized: "mood_check_title", defaultValue: "Mood Check"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var moodTwisty: TwistyMood {
        switch Int(score) {
        case 0..<30: .sad
        case 30..<60: .neutral
        case 60..<80: .happy
        default: .celebrating
        }
    }

    /// Sad image fills more of the frame (no protruding threads), so scale it down slightly
    private var moodTwistySize: CGFloat {
        switch moodTwisty {
        case .sad: 120
        case .neutral: 130
        default: 140
        }
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
        dismiss()
    }
}

#Preview {
    NavigationStack {
        MoodCheckView()
    }
    .modelContainer(for: MoodEntry.self, inMemory: true)
}
