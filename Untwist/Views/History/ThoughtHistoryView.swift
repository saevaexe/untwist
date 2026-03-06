import SwiftUI
import SwiftData

struct ThoughtHistoryView: View {
    @Query(sort: \ThoughtRecord.date, order: .reverse) private var records: [ThoughtRecord]
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var showPaywall = false

    private let freeLimit = 3

    var body: some View {
        ZStack {
            AppScreenBackground(
                primaryTint: Color.primaryPurple.opacity(0.16),
                secondaryTint: Color.secondaryLavender.opacity(0.18),
                tertiaryTint: Color.successGreen.opacity(0.10)
            )

            if records.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
                            let isLocked = !subscriptionManager.hasFullAccess && index >= freeLimit
                            if isLocked {
                                lockedRow(record: record)
                            } else {
                                NavigationLink {
                                    ThoughtRecordDetailView(record: record)
                                } label: {
                                    thoughtRow(record: record)
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
        .navigationTitle(String(localized: "history_thought_title", defaultValue: "Thought History"))
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
                .environment(subscriptionManager)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            TwistyView(mood: .thinking, size: 160)
            Text(String(localized: "history_thought_empty", defaultValue: "No thought records yet"))
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(24)
    }

    private func thoughtRow(record: ThoughtRecord) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.title3)
                .foregroundStyle(Color.primaryPurple)
                .frame(width: 36, height: 36)
                .background(Color.primaryPurple.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(record.event)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    ForEach(record.selectedTraps.prefix(2), id: \.self) { trap in
                        Text(trap.name)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.primaryPurple)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.primaryPurple.opacity(0.10), in: Capsule())
                    }
                }
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 2) {
                moodDelta(record: record)
                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(Color.textSecondary)
            }

            Image(systemName: "chevron.right")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.textSecondary.opacity(0.5))
        }
        .padding(14)
        .elevatedCard(stroke: Color.primaryPurple.opacity(0.14))
    }

    private func lockedRow(record: ThoughtRecord) -> some View {
        Button {
            showPaywall = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .foregroundStyle(Color.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(Color.textSecondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(record.event)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                    Text(record.date.formatted(date: .abbreviated, time: .omitted))
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

    private func moodDelta(record: ThoughtRecord) -> some View {
        let delta = record.moodAfter - record.moodBefore
        let color: Color = delta > 0 ? .successGreen : (delta < 0 ? .crisisWarning : .textSecondary)
        let prefix = delta > 0 ? "+" : ""
        return Text("\(prefix)\(delta)")
            .font(.caption.weight(.bold))
            .foregroundStyle(color)
    }
}

#Preview {
    NavigationStack {
        ThoughtHistoryView()
    }
    .environment(SubscriptionManager.shared)
    .modelContainer(for: ThoughtRecord.self, inMemory: true)
}
