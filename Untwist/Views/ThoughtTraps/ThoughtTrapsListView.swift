import SwiftUI

struct ThoughtTrapsListView: View {
    var body: some View {
        ZStack {
            AppScreenBackground(
                primaryTint: Color.twistyOrange.opacity(0.16),
                secondaryTint: Color.primaryPurple.opacity(0.14),
                tertiaryTint: Color.secondaryLavender.opacity(0.12)
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    headerCard

                    LazyVStack(spacing: 10) {
                        ForEach(ThoughtTrapType.allCases) { trap in
                            NavigationLink {
                                ThoughtTrapDetailView(trap: trap)
                            } label: {
                                trapRow(trap)
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
        .navigationTitle(String(localized: "traps_title", defaultValue: "Thought Traps"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "traps_header_title", defaultValue: "Thought Traps"))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(String(localized: "traps_header_sub", defaultValue: "Learn about common thinking patterns"))
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer(minLength: 0)

            Image(systemName: "lightbulb.fill")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.twistyOrange)
                .frame(width: 42, height: 42)
                .background(Color.twistyOrange.opacity(0.14), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(16)
        .elevatedCard(stroke: Color.twistyOrange.opacity(0.18), shadowColor: .black.opacity(0.07))
    }

    private func trapRow(_ trap: ThoughtTrapType) -> some View {
        HStack(spacing: 14) {
            Image(trap.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 3) {
                Text(trap.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(trap.description)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(14)
        .elevatedCard(stroke: Color.twistyOrange.opacity(0.14), shadowColor: .black.opacity(0.06))
    }
}

#Preview {
    NavigationStack {
        ThoughtTrapsListView()
    }
}
