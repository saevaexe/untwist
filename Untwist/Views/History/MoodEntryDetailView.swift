import SwiftUI

struct MoodEntryDetailView: View {
    let entry: MoodEntry

    var body: some View {
        ZStack {
            AppScreenBackground(
                primaryTint: Color.primaryPurple.opacity(0.15),
                secondaryTint: Color.twistyOrange.opacity(0.14),
                tertiaryTint: Color.successGreen.opacity(0.10)
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    TwistyView(mood: twistyMood, size: 180)

                    Text("\(entry.score)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(moodColor)

                    Text(moodLabel)
                        .font(.headline)
                        .foregroundStyle(Color.textSecondary)

                    if let note = entry.note, !note.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "history_note_label", defaultValue: "Note"))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.textPrimary)

                            Text(note)
                                .font(.subheadline)
                                .foregroundStyle(Color.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(16)
                        .elevatedCard(stroke: Color.primaryPurple.opacity(0.14))
                    }

                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(Color.textSecondary)
                        Text(entry.date.formatted(date: .long, time: .shortened))
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 120)
            }
        }
        .navigationTitle(String(localized: "history_mood_detail_title", defaultValue: "Mood Entry"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var twistyMood: TwistyMood {
        switch entry.score {
        case 0..<20: .sad
        case 20..<40: .neutral
        case 40..<60: .calm
        case 60..<80: .happy
        default: .celebrating
        }
    }

    private var moodColor: Color {
        switch entry.score {
        case 0..<20: .crisisWarning
        case 20..<40: .twistyOrange
        case 40..<60: .secondaryLavender
        case 60..<80: .successGreen
        default: .primaryPurple
        }
    }

    private var moodLabel: String {
        switch entry.score {
        case 0..<20: String(localized: "mood_very_low", defaultValue: "Very Low")
        case 20..<40: String(localized: "mood_low_label", defaultValue: "Low")
        case 40..<60: String(localized: "mood_neutral", defaultValue: "Neutral")
        case 60..<80: String(localized: "mood_good", defaultValue: "Good")
        default: String(localized: "mood_great", defaultValue: "Great")
        }
    }
}
