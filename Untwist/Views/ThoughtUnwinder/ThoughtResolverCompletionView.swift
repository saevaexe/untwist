import SwiftUI
import SwiftData

struct ThoughtResolverCompletionView: View {
    let moodBefore: Int
    let moodAfter: Int
    let selectedTraps: [ThoughtTrapType]
    let onDismiss: () -> Void

    @Query(sort: \ThoughtRecord.date, order: .reverse) private var allRecords: [ThoughtRecord]

    private var moodDelta: Int { moodAfter - moodBefore }
    private var moodProgress: Double { Double(moodAfter) / 100.0 }

    private var weekdayActivity: [Bool] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        // Monday = index 0
        let daysToMonday = (weekday + 5) % 7

        return (0..<7).map { dayIndex in
            guard let date = calendar.date(byAdding: .day, value: -(daysToMonday - dayIndex), to: today) else { return false }
            if date > today { return false }
            return allRecords.contains { calendar.isDate($0.date, inSameDayAs: date) }
        }
    }

    private var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        // If no record today, start from yesterday
        let todayRecords = allRecords.filter { calendar.isDate($0.date, inSameDayAs: checkDate) }
        if todayRecords.isEmpty {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            checkDate = yesterday
        }

        while true {
            let dayRecords = allRecords.filter { calendar.isDate($0.date, inSameDayAs: checkDate) }
            if dayRecords.isEmpty { break }
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }
        return streak
    }

    var body: some View {
        ZStack {
            AppScreenBackground(
                primaryTint: Color.primaryPurple.opacity(0.18),
                secondaryTint: Color.successGreen.opacity(0.16),
                tertiaryTint: Color.twistyOrange.opacity(0.10)
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Twisty celebrating
                    TwistyView(mood: .celebrating, size: 100)
                        .padding(.top, 8)

                    // Title
                    Text(String(localized: "completion_title", defaultValue: "Great work!"))
                        .font(.title.weight(.bold))
                        .foregroundStyle(Color.textPrimary)

                    // Mood comparison card
                    moodComparisonCard

                    // Encouragement text
                    encouragementText

                    // Thought traps card
                    if !selectedTraps.isEmpty {
                        trapsSummaryCard
                    }

                    // Streak
                    if currentStreak > 0 {
                        streakPill
                    }

                    // Done button
                    Button {
                        onDismiss()
                    } label: {
                        Text(String(localized: "completion_done", defaultValue: "Done"))
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
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Mood Comparison

    private var moodComparisonCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                moodColumn(
                    label: String(localized: "completion_mood_before", defaultValue: "Before"),
                    value: moodBefore
                )

                Image(systemName: moodDelta > 0 ? "arrow.right" : "arrow.right")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(moodDelta > 0 ? Color.successGreen : Color.twistyOrange)

                moodColumn(
                    label: String(localized: "completion_mood_after", defaultValue: "After"),
                    value: moodAfter
                )
            }

            // Progress bar
            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 99)
                            .fill(Color.appBackground)
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 99)
                            .fill(
                                LinearGradient(
                                    colors: [Color.twistyOrange, Color.successGreen],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * moodProgress, height: 6)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text(String(localized: "completion_progress_low", defaultValue: "Low"))
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                    if moodDelta > 0 {
                        Text("+\(moodDelta) \(String(localized: "stats_pts", defaultValue: "pts")) \u{2191}")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.successGreen)
                    }
                    Spacer()
                    Text(String(localized: "completion_progress_great", defaultValue: "Great"))
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .padding(.top, 4)
        }
        .padding(20)
        .elevatedCard(stroke: Color.primaryPurple.opacity(0.16), shadowColor: Color.primaryPurple.opacity(0.10))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(localized: "completion_accessibility_mood", defaultValue: "Mood changed from \(moodBefore) to \(moodAfter)"))
    }

    private func moodColumn(label: String, value: Int) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.textSecondary)

            Text("\(value)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(Color.primaryPurple)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Encouragement

    private var encouragementText: some View {
        Group {
            if moodDelta > 0 {
                Text(String(localized: "completion_mood_improved", defaultValue: "Your mood improved by \(moodDelta) points. That's the power of looking at things differently."))
            } else if moodDelta == 0 {
                Text(String(localized: "completion_mood_same", defaultValue: "Your mood stayed the same — and that's okay. You still took time to reflect, and that matters."))
            } else {
                Text(String(localized: "completion_mood_notice", defaultValue: "You noticed how you feel, and that awareness is a big step. Keep going."))
            }
        }
        .font(.subheadline)
        .foregroundStyle(Color.textSecondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 8)
    }

    // MARK: - Traps Summary

    private var trapsSummaryCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                ForEach(selectedTraps, id: \.self) { trap in
                    Image(trap.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                }
            }

            Text(String(
                format: String(localized: "completion_traps_found", defaultValue: "You spotted %lld thought trap(s)"),
                locale: Locale.current,
                Int64(selectedTraps.count)
            ))
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.textPrimary)

            Text(String(localized: "completion_traps_insight", defaultValue: "Recognizing patterns is the first step to breaking free from them."))
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(18)
        .elevatedCard(stroke: Color.twistyOrange.opacity(0.18), shadowColor: .black.opacity(0.07))
    }

    // MARK: - Streak

    private var weekdayLabels: [String] {
        let symbols = Calendar.current.veryShortWeekdaySymbols
        // Calendar returns Sun=0, reorder to Mon=0
        return Array(symbols[1...]) + [symbols[0]]
    }

    private var streakPill: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.title3)
                    .foregroundStyle(Color.twistyOrange)

                VStack(alignment: .leading, spacing: 2) {
                    if currentStreak == 1 {
                        Text(String(localized: "completion_streak_first", defaultValue: "First entry — the journey begins!"))
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                    } else {
                        Text(String(
                            format: String(localized: "completion_streak", defaultValue: "%lld day streak"),
                            locale: Locale.current,
                            Int64(currentStreak)
                        ))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                    }

                    Text(String(localized: "completion_streak_today", defaultValue: "Completed today"))
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.65))
                }

                Spacer()

                // Weekday indicators
                HStack(spacing: 3) {
                    let todayIndex = (Calendar.current.component(.weekday, from: Date()) + 5) % 7
                    ForEach(0..<7, id: \.self) { index in
                        let isToday = todayIndex == index
                        let isActive = index < weekdayActivity.count && weekdayActivity[index]

                        Text(weekdayLabels[index])
                            .font(.system(size: 8, weight: .bold))
                            .frame(width: 20, height: 20)
                            .background(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(isToday ? Color.twistyOrange : (isActive ? .white.opacity(0.9) : .white.opacity(0.15)))
                            )
                            .foregroundStyle(isToday ? .white : (isActive ? Color.primaryPurple : .white.opacity(0.4)))
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.primaryPurple)
        )
        .shadow(color: Color.primaryPurple.opacity(0.20), radius: 10, y: 4)
    }
}

#Preview {
    ThoughtResolverCompletionView(
        moodBefore: 35,
        moodAfter: 65,
        selectedTraps: [.allOrNothing, .magnification],
        onDismiss: {}
    )
    .modelContainer(for: ThoughtRecord.self, inMemory: true)
}
