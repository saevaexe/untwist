import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    @Query(sort: \MoodEntry.date, order: .reverse) private var moodEntries: [MoodEntry]
    @Query private var thoughtRecords: [ThoughtRecord]
    @Query private var breathingSessions: [BreathingSession]

    @AppStorage("rc_insights_viewed") private var hasTrackedInsights = false
    @State private var selectedPeriod = 1 // 0=7d, 1=month, 2=all

    private enum Period: Int, CaseIterable {
        case week = 0, month, all

        var label: String {
            switch self {
            case .week: String(localized: "period_week", defaultValue: "7 Days")
            case .month: String(localized: "period_month", defaultValue: "This Month")
            case .all: String(localized: "period_all", defaultValue: "All")
            }
        }

        var startDate: Date? {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            switch self {
            case .week: return calendar.date(byAdding: .day, value: -7, to: today)
            case .month: return calendar.date(from: calendar.dateComponents([.year, .month], from: today))
            case .all: return nil
            }
        }
    }

    private var period: Period { Period(rawValue: selectedPeriod) ?? .month }

    private func filterByPeriod<T>(_ items: [T], dateKeyPath: KeyPath<T, Date>) -> [T] {
        guard let start = period.startDate else { return items }
        return items.filter { $0[keyPath: dateKeyPath] >= start }
    }

    private var filteredMoods: [MoodEntry] { filterByPeriod(moodEntries, dateKeyPath: \.date) }
    private var filteredRecords: [ThoughtRecord] { filterByPeriod(thoughtRecords, dateKeyPath: \.date) }
    private var filteredSessions: [BreathingSession] { filterByPeriod(breathingSessions, dateKeyPath: \.date) }

    // MARK: - Computed Properties

    private var totalEntries: Int {
        filteredMoods.count + filteredRecords.count + filteredSessions.count
    }

    private var averageMood: Double {
        guard !filteredMoods.isEmpty else { return 0 }
        return Double(filteredMoods.map(\.score).reduce(0, +)) / Double(filteredMoods.count)
    }

    private var improvementRate: Double {
        guard !filteredRecords.isEmpty else { return 0 }
        let total = filteredRecords.map { $0.moodAfter - $0.moodBefore }.reduce(0, +)
        return Double(total) / Double(filteredRecords.count)
    }

    private var currentStreak: Int {
        let calendar = Calendar.current
        var allDates = Set<Date>()

        for entry in moodEntries {
            allDates.insert(calendar.startOfDay(for: entry.date))
        }
        for record in thoughtRecords {
            allDates.insert(calendar.startOfDay(for: record.date))
        }
        for session in breathingSessions {
            allDates.insert(calendar.startOfDay(for: session.date))
        }

        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        // If no entry today, start from yesterday
        if !allDates.contains(checkDate) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            checkDate = yesterday
        }

        while allDates.contains(checkDate) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }
        return streak
    }

    private let trapColors: [Color] = [.primaryPurple, .crisisWarning, .twistyOrange, .successGreen, .secondaryLavender]

    private var trapFrequency: [(trap: ThoughtTrapType, count: Int)] {
        var counts: [ThoughtTrapType: Int] = [:]
        for record in filteredRecords {
            for trap in record.selectedTraps {
                counts[trap, default: 0] += 1
            }
        }
        return counts
            .map { (trap: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    private var activityCounts: [Date: Int] {
        let calendar = Calendar.current
        var counts: [Date: Int] = [:]
        for entry in filteredMoods {
            let day = calendar.startOfDay(for: entry.date)
            counts[day, default: 0] += 1
        }
        for record in filteredRecords {
            let day = calendar.startOfDay(for: record.date)
            counts[day, default: 0] += 1
        }
        for session in filteredSessions {
            let day = calendar.startOfDay(for: session.date)
            counts[day, default: 0] += 1
        }
        return counts
    }

    private func heatmapColor(for count: Int) -> Color {
        switch count {
        case 0: return Color.primaryPurple.opacity(0.10)
        case 1: return Color.primaryPurple.opacity(0.30)
        case 2: return Color.primaryPurple.opacity(0.55)
        default: return Color.primaryPurple
        }
    }

    private var activityCalendarAnchorDate: Date {
        let dates = activityCounts.keys.sorted()
        return dates.last ?? Date()
    }

    private var activityCalendarMonthName: String {
        let month = activityCalendarAnchorDate.formatted(.dateTime.month(.wide))
        return month.capitalized(with: .autoupdatingCurrent)
    }

    private var activityCalendarTitle: String {
        let isTurkish = Locale.autoupdatingCurrent.identifier.lowercased().hasPrefix("tr")
        let baseTitle = isTurkish ? "Aktivite Takvimi" : "Activity Calendar"
        return "\(baseTitle) — \(activityCalendarMonthName)"
    }

    private var activityCalendarWeeks: [[Date?]] {
        let calendar = Calendar.current
        let anchor = activityCalendarAnchorDate
        guard
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: anchor)),
            let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count
        else { return [] }

        let firstWeekdayInMonth = calendar.component(.weekday, from: monthStart)
        let leadingEmptyDays = (firstWeekdayInMonth - calendar.firstWeekday + 7) % 7

        var slots: [Date?] = Array(repeating: nil, count: leadingEmptyDays)
        for offset in 0..<daysInMonth {
            if let date = calendar.date(byAdding: .day, value: offset, to: monthStart) {
                slots.append(date)
            }
        }

        while slots.count % 7 != 0 {
            slots.append(nil)
        }

        var weeks: [[Date?]] = []
        for index in stride(from: 0, to: slots.count, by: 7) {
            weeks.append(Array(slots[index..<min(index + 7, slots.count)]))
        }
        return weeks
    }

    // MARK: - Weekly Summary Computed Properties

    private var weeklySummaryData: (moodTrend: String, topTrap: String?, activityCount: Int, twistyMood: TwistyMood) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) else {
            return ("stable", nil, 0, .neutral)
        }

        let weekMoods = moodEntries.filter { $0.date >= weekAgo }
        let weekRecords = thoughtRecords.filter { $0.date >= weekAgo }
        let weekSessions = breathingSessions.filter { $0.date >= weekAgo }
        let activityCount = weekMoods.count + weekRecords.count + weekSessions.count

        // Mood trend: compare first half vs second half
        let midpoint = calendar.date(byAdding: .day, value: -3, to: today)!
        let firstHalf = weekMoods.filter { $0.date >= weekAgo && $0.date < midpoint }
        let secondHalf = weekMoods.filter { $0.date >= midpoint }

        let firstAvg = firstHalf.isEmpty ? 50.0 : Double(firstHalf.map(\.score).reduce(0, +)) / Double(firstHalf.count)
        let secondAvg = secondHalf.isEmpty ? 50.0 : Double(secondHalf.map(\.score).reduce(0, +)) / Double(secondHalf.count)
        let diff = secondAvg - firstAvg

        let trend: String
        let twistyMood: TwistyMood
        if diff > 5 {
            trend = "up"
            twistyMood = .happy
        } else if diff < -5 {
            trend = "down"
            twistyMood = .sad
        } else {
            trend = "stable"
            twistyMood = .neutral
        }

        // Top trap
        var trapCounts: [ThoughtTrapType: Int] = [:]
        for record in weekRecords {
            for trap in record.selectedTraps {
                trapCounts[trap, default: 0] += 1
            }
        }
        let topTrap = trapCounts.max(by: { $0.value < $1.value })?.key.name

        return (trend, topTrap, activityCount, twistyMood)
    }

    // MARK: - Breathing Stats Data

    private var breathingTotalMinutes: Double {
        filteredSessions.map(\.duration).reduce(0, +) / 60.0
    }

    private var breathingTotalRounds: Int {
        filteredSessions.map(\.rounds).reduce(0, +)
    }

    private var breathingLongestMinutes: Double {
        (filteredSessions.map(\.duration).max() ?? 0) / 60.0
    }

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
                        periodTabs

                        overallMetricsSection

                        weeklySummarySection

                        if !last7DaysMoods.isEmpty {
                            moodChartSection
                        }

                        trapFrequencySection

                        if !filteredSessions.isEmpty {
                            breathingStatsSection
                        }

                        activityHeatmapSection

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
        .onAppear {
            if !hasTrackedInsights {
                AnalyticsManager.trackMilestone(.insightsViewed)
                hasTrackedInsights = true
            }
        }
    }

    // MARK: - Period Tabs

    private var periodTabs: some View {
        HStack(spacing: 4) {
            ForEach(Period.allCases, id: \.rawValue) { p in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedPeriod = p.rawValue }
                } label: {
                    Text(p.label)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(selectedPeriod == p.rawValue ? .white : Color.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(selectedPeriod == p.rawValue ? Color.primaryPurple : Color.clear)
                                .shadow(color: selectedPeriod == p.rawValue ? Color.primaryPurple.opacity(0.25) : .clear, radius: 6, y: 2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 14) {
            TwistyView(mood: .thinking, size: 200)

            Text(String(localized: "insights_no_data", defaultValue: "Start recording to see your trends"))
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(24)
        .elevatedCard(stroke: Color.primaryPurple.opacity(0.18), shadowColor: Color.primaryPurple.opacity(0.12))
    }

    // MARK: - Overall Metrics (2x2 Grid)

    private var overallMetricsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            metricCard(
                value: "\(totalEntries)",
                label: String(localized: "stats_total_entries", defaultValue: "Total Entries"),
                icon: "square.stack.fill",
                color: .primaryPurple
            )

            metricCard(
                value: moodEntries.isEmpty ? "—" : String(format: "%.0f", averageMood),
                label: String(localized: "stats_avg_mood", defaultValue: "Avg Mood"),
                icon: "face.smiling",
                color: .twistyOrange
            )

            metricCard(
                value: thoughtRecords.isEmpty ? "—" : String(format: "%+.0f \(String(localized: "stats_pts", defaultValue: "pts"))", improvementRate),
                label: String(localized: "stats_improvement", defaultValue: "Improvement"),
                icon: "arrow.up.right",
                color: .successGreen
            )

            metricCard(
                value: currentStreak == 0 ? "—" : "\(currentStreak) \(String(localized: "stats_days", defaultValue: "days"))",
                label: String(localized: "stats_streak", defaultValue: "Streak"),
                icon: "flame.fill",
                color: .twistyOrange
            )
        }
    }

    private func metricCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .elevatedCard(cornerRadius: 18, stroke: color.opacity(0.14), shadowColor: .black.opacity(0.06))
    }

    // MARK: - Mood Chart (Enhanced with AreaMark)

    private var moodChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "insights_mood_trend", defaultValue: "Mood Trend (7 Days)"))
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            Chart {
                ForEach(last7DaysMoods, id: \.date) { entry in
                    AreaMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Mood", entry.average)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.primaryPurple.opacity(0.3), Color.primaryPurple.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

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

    // MARK: - Trap Frequency

    private var trapFrequencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "stats_trap_frequency", defaultValue: "Top Thought Traps"))
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            if trapFrequency.isEmpty {
                Text(String(localized: "stats_no_traps", defaultValue: "Complete thought records to see patterns"))
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                let top5 = Array(trapFrequency.prefix(5))
                VStack(spacing: 8) {
                    ForEach(Array(top5.enumerated()), id: \.element.trap) { index, item in
                        let color = trapColors[index % trapColors.count]
                        let maxCount = top5.first?.count ?? 1
                        HStack(spacing: 10) {
                            Image(item.trap.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 28, height: 28)
                                .padding(4)
                                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 9, style: .continuous))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.trap.name)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color.textPrimary)

                                GeometryReader { geo in
                                    RoundedRectangle(cornerRadius: 99)
                                        .fill(Color.appBackground)
                                        .frame(height: 5)
                                        .overlay(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 99)
                                                .fill(color)
                                                .frame(width: geo.size.width * CGFloat(item.count) / CGFloat(maxCount), height: 5)
                                        }
                                }
                                .frame(height: 5)
                            }

                            Text("\u{00D7}\(item.count)")
                                .font(.caption.weight(.heavy))
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                }
            }
        }
        .padding(18)
        .elevatedCard(stroke: Color.twistyOrange.opacity(0.16), shadowColor: .black.opacity(0.07))
    }

    // MARK: - Activity Heatmap

    private var activityHeatmapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(activityCalendarTitle)
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            if activityCounts.isEmpty {
                Text(String(localized: "stats_no_data_yet", defaultValue: "Your activity will appear here"))
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(activityCalendarWeeks.enumerated()), id: \.offset) { _, week in
                        HStack(spacing: 8) {
                            ForEach(Array(week.enumerated()), id: \.offset) { _, day in
                                Group {
                                    if let day {
                                        let count = activityCounts[day] ?? 0
                                        let isToday = Calendar.current.isDateInToday(day)
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(heatmapColor(for: count))
                                            .overlay {
                                                if isToday {
                                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                        .stroke(Color.cardBackground, lineWidth: 2)
                                                        .padding(1)
                                                }
                                            }
                                            .overlay {
                                                if isToday {
                                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                        .stroke(Color.primaryPurple, lineWidth: 2)
                                                }
                                            }
                                    } else {
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(Color.clear)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                            }
                        }
                    }
                }
            }
        }
        .padding(18)
        .elevatedCard(cornerRadius: 22, stroke: Color.primaryPurple.opacity(0.14), shadowColor: .black.opacity(0.08))
    }

    // MARK: - Weekly Summary

    private var weeklySummarySection: some View {
        let data = weeklySummaryData
        let trendText: String = switch data.moodTrend {
        case "up": String(localized: "insights_weekly_mood_up", defaultValue: "Your mood is trending up this week")
        case "down": String(localized: "insights_weekly_mood_down", defaultValue: "Your mood dipped a bit this week")
        default: String(localized: "insights_weekly_mood_stable", defaultValue: "Your mood has been steady this week")
        }

        return VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "insights_weekly_summary", defaultValue: "Weekly Summary"))
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            HStack(spacing: 14) {
                TwistyView(mood: data.twistyMood, size: 56)

                VStack(alignment: .leading, spacing: 6) {
                    Text(trendText)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.textPrimary)

                    HStack(spacing: 12) {
                        Label("\(data.activityCount) \(String(localized: "insights_weekly_activities", defaultValue: "activities this week"))", systemImage: "chart.bar.fill")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                    }

                    if let topTrap = data.topTrap {
                        Label("\(String(localized: "insights_weekly_top_trap", defaultValue: "Most common trap")): \(topTrap)", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.twistyOrange)
                    }
                }
            }
        }
        .padding(18)
        .elevatedCard(stroke: Color.primaryPurple.opacity(0.16), shadowColor: Color.primaryPurple.opacity(0.11))
    }

    // MARK: - Breathing Stats

    private var breathingStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "insights_breathing_stats", defaultValue: "Breathing Stats"))
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            HStack(spacing: 12) {
                breathingMetricCard(
                    value: String(format: "%.0f", breathingTotalMinutes),
                    unit: String(localized: "insights_min", defaultValue: "min"),
                    label: String(localized: "insights_total_time", defaultValue: "Total Time"),
                    icon: "clock.fill",
                    color: .successGreen
                )

                breathingMetricCard(
                    value: "\(breathingTotalRounds)",
                    unit: "",
                    label: String(localized: "insights_total_rounds", defaultValue: "Total Rounds"),
                    icon: "arrow.2.circlepath",
                    color: .primaryPurple
                )

                breathingMetricCard(
                    value: String(format: "%.1f", breathingLongestMinutes),
                    unit: String(localized: "insights_min", defaultValue: "min"),
                    label: String(localized: "insights_longest_session", defaultValue: "Longest"),
                    icon: "trophy.fill",
                    color: .twistyOrange
                )
            }
        }
        .padding(18)
        .elevatedCard(stroke: Color.successGreen.opacity(0.16), shadowColor: .black.opacity(0.07))
    }

    private func breathingMetricCard(value: String, unit: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(color)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.textPrimary)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption2)
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)

            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Stats (original 3-column grid, preserved)

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
