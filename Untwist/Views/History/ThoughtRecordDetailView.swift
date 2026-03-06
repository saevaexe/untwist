import SwiftUI

struct ThoughtRecordDetailView: View {
    let record: ThoughtRecord

    var body: some View {
        ZStack {
            AppScreenBackground(
                primaryTint: Color.primaryPurple.opacity(0.16),
                secondaryTint: Color.secondaryLavender.opacity(0.18),
                tertiaryTint: Color.successGreen.opacity(0.10)
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Step 1: Event
                    stepCard(
                        number: "1",
                        title: String(localized: "history_detail_event", defaultValue: "What happened"),
                        content: record.event,
                        color: .primaryPurple
                    )

                    // Step 2: Thought + mood before
                    VStack(alignment: .leading, spacing: 10) {
                        stepHeader(number: "2", title: String(localized: "history_detail_thought", defaultValue: "Automatic thought"), color: .secondaryLavender)

                        Text(record.automaticThought)
                            .font(.subheadline)
                            .foregroundStyle(Color.textPrimary)

                        moodBadge(
                            label: String(localized: "history_detail_mood_before", defaultValue: "Mood before"),
                            score: record.moodBefore
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .elevatedCard(stroke: Color.secondaryLavender.opacity(0.20))

                    // Step 3: Traps
                    VStack(alignment: .leading, spacing: 10) {
                        stepHeader(number: "3", title: String(localized: "history_detail_traps", defaultValue: "Thought traps"), color: .twistyOrange)

                        if record.selectedTraps.isEmpty {
                            Text(String(localized: "history_detail_no_traps", defaultValue: "No traps selected"))
                                .font(.caption)
                                .foregroundStyle(Color.textSecondary)
                        } else {
                            FlowLayoutView(spacing: 8) {
                                ForEach(record.selectedTraps, id: \.self) { trap in
                                    HStack(spacing: 4) {
                                        Image(trap.imageName)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 18, height: 18)
                                        Text(trap.name)
                                            .font(.caption.weight(.semibold))
                                    }
                                    .foregroundStyle(Color.twistyOrange)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.twistyOrange.opacity(0.10), in: Capsule())
                                }
                            }
                        }
                    }
                    .padding(16)
                    .elevatedCard(stroke: Color.twistyOrange.opacity(0.18))

                    // Step 4: Alternative + mood after
                    VStack(alignment: .leading, spacing: 10) {
                        stepHeader(number: "4", title: String(localized: "history_detail_alternative", defaultValue: "Alternative thought"), color: .successGreen)

                        Text(record.alternativeThought)
                            .font(.subheadline)
                            .foregroundStyle(Color.textPrimary)

                        moodBadge(
                            label: String(localized: "history_detail_mood_after", defaultValue: "Mood after"),
                            score: record.moodAfter
                        )
                    }
                    .padding(16)
                    .elevatedCard(stroke: Color.successGreen.opacity(0.18))

                    // Mood change summary
                    moodChangeSummary
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 120)
            }
        }
        .navigationTitle(String(localized: "history_detail_title", defaultValue: "Thought Record"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func stepCard(number: String, title: String, content: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            stepHeader(number: number, title: title, color: color)
            Text(content)
                .font(.subheadline)
                .foregroundStyle(Color.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .elevatedCard(stroke: color.opacity(0.18))
    }

    private func stepHeader(number: String, title: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Text(number)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(color, in: Circle())

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
        }
    }

    private func moodBadge(label: String, score: Int) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
            Text("\(score)")
                .font(.caption.weight(.bold))
                .foregroundStyle(moodColor(for: score))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(moodColor(for: score).opacity(0.12), in: Capsule())
        }
    }

    private var moodChangeSummary: some View {
        let delta = record.moodAfter - record.moodBefore
        let color: Color = delta > 0 ? .successGreen : (delta < 0 ? .crisisWarning : .textSecondary)
        let prefix = delta > 0 ? "+" : ""

        return HStack(spacing: 16) {
            VStack(spacing: 2) {
                Text(String(localized: "history_detail_before", defaultValue: "Before"))
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                Text("\(record.moodBefore)")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(moodColor(for: record.moodBefore))
            }

            Image(systemName: "arrow.right")
                .font(.title3)
                .foregroundStyle(Color.textSecondary)

            VStack(spacing: 2) {
                Text(String(localized: "history_detail_after", defaultValue: "After"))
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                Text("\(record.moodAfter)")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(moodColor(for: record.moodAfter))
            }

            Spacer()

            VStack(spacing: 2) {
                Text(String(localized: "history_detail_change", defaultValue: "Change"))
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                Text("\(prefix)\(delta)")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(color)
            }
        }
        .padding(16)
        .elevatedCard(stroke: color.opacity(0.20))
    }

    private func moodColor(for score: Int) -> Color {
        switch score {
        case 0..<20: .crisisWarning
        case 20..<40: .twistyOrange
        case 40..<60: .secondaryLavender
        case 60..<80: .successGreen
        default: .primaryPurple
        }
    }
}

// Simple flow layout for trap badges
private struct FlowLayoutView: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentY += rowHeight + spacing
                currentX = 0
                rowHeight = 0
            }
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: currentY + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX, currentX > bounds.minX {
                currentY += rowHeight + spacing
                currentX = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
