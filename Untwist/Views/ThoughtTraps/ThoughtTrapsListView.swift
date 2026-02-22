import SwiftUI

struct ThoughtTrapsListView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(ThoughtTrapType.allCases) { trap in
                    NavigationLink {
                        ThoughtTrapDetailView(trap: trap)
                    } label: {
                        HStack(spacing: 16) {
                            Image(trap.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(trap.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Color.textPrimary)
                                Text(trap.description)
                                    .font(.caption)
                                    .foregroundStyle(Color.textSecondary)
                                    .lineLimit(2)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(Color.textSecondary)
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background(Color.appBackground)
        .navigationTitle(String(localized: "traps_title", defaultValue: "Thought Traps"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ThoughtTrapsListView()
    }
}
