import SwiftUI

struct ThoughtTrapDetailView: View {
    let trap: ThoughtTrapType

    var body: some View {
        ZStack {
            AppScreenBackground(
                primaryTint: Color.twistyOrange.opacity(0.16),
                secondaryTint: Color.primaryPurple.opacity(0.14),
                tertiaryTint: Color.successGreen.opacity(0.10)
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    // Header with icon
                    VStack(spacing: 14) {
                        Image(trap.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80)

                        Text(trap.name)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(22)
                    .elevatedCard(stroke: Color.twistyOrange.opacity(0.20), shadowColor: Color.twistyOrange.opacity(0.12))

                    // Description
                    infoSection(
                        icon: "doc.text.fill",
                        title: String(localized: "trap_detail_what", defaultValue: "What is it?"),
                        content: trap.description,
                        tint: .primaryPurple
                    )

                    // Examples
                    examplesSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 120)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var examplesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "quote.bubble.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.secondaryLavender)
                Text(String(localized: "trap_detail_examples", defaultValue: "Examples"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
            }

            ForEach(Array(trap.examples.enumerated()), id: \.offset) { _, example in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "text.quote")
                        .font(.caption2)
                        .foregroundStyle(Color.secondaryLavender.opacity(0.7))
                        .padding(.top, 3)
                    Text(example)
                        .font(.body)
                        .italic()
                        .foregroundStyle(Color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .elevatedCard(stroke: Color.secondaryLavender.opacity(0.18), shadowColor: .black.opacity(0.07))
    }

    private func infoSection(icon: String, title: String, content: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(tint)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
            }

            Text(content)
                .font(.body)
                .foregroundStyle(Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .elevatedCard(stroke: tint.opacity(0.18), shadowColor: .black.opacity(0.07))
    }
}

#Preview {
    NavigationStack {
        ThoughtTrapDetailView(trap: .allOrNothing)
    }
}
