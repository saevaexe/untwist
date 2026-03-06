import SwiftUI
import SwiftData

struct MoodHistoryView: View {
    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var showPaywall = false

    private let freeLimit = 3

    var body: some View {
        ZStack {
            AppScreenBackground(
                primaryTint: Color.primaryPurple.opacity(0.15),
                secondaryTint: Color.twistyOrange.opacity(0.14),
                tertiaryTint: Color.successGreen.opacity(0.10)
            )

            if entries.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                            let isLocked = !subscriptionManager.hasFullAccess && index >= freeLimit
                            if isLocked {
                                lockedRow(entry: entry)
                            } else {
                                NavigationLink {
                                    MoodEntryDetailView(entry: entry)
                                } label: {
                                    moodRow(entry: entry)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 120)
                }
            }
        }
        .navigationTitle(String(localized: "history_mood_title", defaultValue: "Mood History"))
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
                .environment(subscriptionManager)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            TwistyView(mood: .thinking, size: 160)
            Text(String(localized: "history_mood_empty", defaultValue: "No mood entries yet"))
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(24)
    }

    private func moodRow(entry: MoodEntry) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(moodColor(for: entry.score))
                .frame(width: 36, height: 36)
                .overlay {
                    Text("\(entry.score)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(moodLabel(for: entry.score))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)

                if let note = entry.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundStyle(Color.textSecondary)

            Image(systemName: "chevron.right")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.textSecondary.opacity(0.5))
        }
        .padding(14)
        .elevatedCard(stroke: moodColor(for: entry.score).opacity(0.16))
    }

    private func lockedRow(entry: MoodEntry) -> some View {
        Button {
            showPaywall = true
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.textSecondary.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(moodLabel(for: entry.score))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textSecondary)
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary.opacity(0.6))
                }

                Spacer(minLength: 0)

                Image(systemName: "crown.fill")
                    .font(.caption)
                    .foregroundStyle(Color.primaryPurple)
            }
            .padding(14)
            .elevatedCard(stroke: Color.textSecondary.opacity(0.12))
            .opacity(0.6)
        }
        .buttonStyle(.plain)
    }

    private func moodColor(for score: Int) -> Color {
        switch score {
        case 0..<20: Color.crisisWarning
        case 20..<40: Color.twistyOrange
        case 40..<60: Color.secondaryLavender
        case 60..<80: Color.successGreen
        default: Color.primaryPurple
        }
    }

    private func moodLabel(for score: Int) -> String {
        switch score {
        case 0..<20: String(localized: "mood_very_low", defaultValue: "Very Low")
        case 20..<40: String(localized: "mood_low_label", defaultValue: "Low")
        case 40..<60: String(localized: "mood_neutral", defaultValue: "Neutral")
        case 60..<80: String(localized: "mood_good", defaultValue: "Good")
        default: String(localized: "mood_great", defaultValue: "Great")
        }
    }
}

#Preview {
    NavigationStack {
        MoodHistoryView()
    }
    .environment(SubscriptionManager.shared)
    .modelContainer(for: MoodEntry.self, inMemory: true)
}
