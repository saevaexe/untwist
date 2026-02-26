import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    @Query(sort: \MoodEntry.date, order: .reverse) private var moodEntries: [MoodEntry]
    @Query private var thoughtRecords: [ThoughtRecord]
    @Query private var breathingSessions: [BreathingSession]

    private var last7DaysMoods: [(date: Date, average: Double)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<7).reversed().compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { return nil }
            let nextDay = calendar.date(byAdding: .day, value: 1, to: date)!
            let dayEntries = moodEntries.filter { $0.date >= date && $0.date < nextDay }
            guard !dayEntries.isEmpty else { return nil }
            let avg = Double(dayEntries.map(\.score).reduce(0, +)) / Double(dayEntries.count)
            return (date: date, average: avg)
        }
    }

    var body: some View {
        ZStack {
            AppScreenBackground(
                primaryTint: Color.primaryPurple.opacity(0.16),
                secondaryTint: Color.successGreen.opacity(0.14),
                tertiaryTint: Color.twistyOrange.opacity(0.12)
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    if moodEntries.isEmpty && thoughtRecords.isEmpty && breathingSessions.isEmpty {
                        emptyStateView
                    } else {
                        headerSummaryCard

                        if !last7DaysMoods.isEmpty {
                            moodChartSection
                        }
                        statsSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 120)
            }
        }
        .navigationTitle(String(localized: "insights_title", defaultValue: "Insights"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 14) {
            TwistyView(mood: .thinking, size: 140)

            Text(String(localized: "insights_no_data", defaultValue: "Start recording to see your trends"))
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(24)
        .elevatedCard(stroke: Color.primaryPurple.opacity(0.18), shadowColor: Color.primaryPurple.opacity(0.12))
    }

    private var headerSummaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(String(localized: "insights_header_title", defaultValue: "Your weekly snapshot"))
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.textPrimary)

            Text(String(localized: "insights_header_sub", defaultValue: "Small steps count. This is your progress this week."))
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)

            HStack(spacing: 12) {
                summaryPill(
                    value: "\(moodEntries.count)",
                    label: String(localized: "insights_mood_checks", defaultValue: "Mood Checks"),
                    color: .primaryPurple
                )

                summaryPill(
                    value: "\(thoughtRecords.count)",
                    label: String(localized: "insights_thought_records", defaultValue: "Thought Records"),
                    color: .secondaryLavender
                )

                summaryPill(
                    value: "\(breathingSessions.count)",
                    label: String(localized: "insights_breathing_sessions", defaultValue: "Breathing Sessions"),
                    color: .successGreen
                )
            }
        }
        .padding(18)
        .elevatedCard(stroke: Color.primaryPurple.opacity(0.16), shadowColor: Color.primaryPurple.opacity(0.12))
    }

    private func summaryPill(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(color.opacity(0.10), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    // MARK: - Mood Chart

    private var moodChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "insights_mood_trend", defaultValue: "Mood Trend (7 Days)"))
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            Chart {
                ForEach(last7DaysMoods, id: \.date) { entry in
                    LineMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Mood", entry.average)
                    )
                    .foregroundStyle(Color.primaryPurple)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Mood", entry.average)
                    )
                    .foregroundStyle(Color.primaryPurple)
                }

                RuleMark(y: .value("Baseline", 50))
                    .foregroundStyle(Color.textSecondary.opacity(0.3))
                    .lineStyle(StrokeStyle(dash: [5, 5]))
            }
            .chartYScale(domain: 0...100)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                }
            }
            .frame(height: 200)
            .padding(16)
            .elevatedCard(stroke: Color.primaryPurple.opacity(0.16), shadowColor: Color.primaryPurple.opacity(0.11))
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "insights_stats", defaultValue: "Your Activity"))
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statCard(
                    count: moodEntries.count,
                    label: String(localized: "insights_mood_checks", defaultValue: "Mood Checks"),
                    icon: "face.smiling",
                    color: .primaryPurple
                )

                statCard(
                    count: thoughtRecords.count,
                    label: String(localized: "insights_thought_records", defaultValue: "Thought Records"),
                    icon: "brain.head.profile",
                    color: .secondaryLavender
                )

                statCard(
                    count: breathingSessions.count,
                    label: String(localized: "insights_breathing_sessions", defaultValue: "Breathing Sessions"),
                    icon: "wind",
                    color: .successGreen
                )
            }
        }
        .padding(18)
        .elevatedCard(stroke: Color.secondaryLavender.opacity(0.24), shadowColor: .black.opacity(0.08))
    }

    private func statCard(count: Int, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text("\(count)")
                .font(.title.weight(.bold))
                .foregroundStyle(Color.textPrimary)

            Text(label)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        InsightsView()
    }
    .modelContainer(for: [MoodEntry.self, ThoughtRecord.self, BreathingSession.self], inMemory: true)
}
