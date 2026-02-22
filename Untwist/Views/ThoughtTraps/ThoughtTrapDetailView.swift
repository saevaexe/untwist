import SwiftUI

struct ThoughtTrapDetailView: View {
    let trap: ThoughtTrapType

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.twistyOrange)

                    Text(trap.name)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)

                // Description
                infoSection(
                    title: String(localized: "trap_detail_what", defaultValue: "What is it?"),
                    content: trap.description
                )

                // Example
                infoSection(
                    title: String(localized: "trap_detail_example", defaultValue: "Example"),
                    content: trap.example
                )
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .background(Color.appBackground)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.primaryPurple)

            Text(content)
                .font(.body)
                .foregroundStyle(Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NavigationStack {
        ThoughtTrapDetailView(trap: .allOrNothing)
    }
}
