import SwiftUI

struct HomeView: View {
    @State private var showUnwinding = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Twisty greeting
                VStack(spacing: 8) {
                    TwistyView(mood: .happy, size: 160)

                    Text(String(localized: "home_greeting", defaultValue: "Hey there! How are you today?"))
                        .font(.title3.weight(.medium))
                        .foregroundStyle(Color.textPrimary)
                }
                .padding(.top, 20)

                // Unwinding Now — quick action
                Button {
                    showUnwinding = true
                } label: {
                    HStack(spacing: 16) {
                        TwistyView(mood: .breathing, size: 50, animated: false)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(localized: "home_unwinding_now", defaultValue: "Unwinding Now"))
                                .font(.headline)
                                .foregroundStyle(Color.textPrimary)
                            Text(String(localized: "home_unwinding_now_sub", defaultValue: "Feeling overwhelmed?"))
                                .font(.subheadline)
                                .foregroundStyle(Color.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .padding()
                    .background(Color.twistyOrange.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                }
                .padding(.horizontal)

                // Action cards
                VStack(spacing: 12) {
                    ActionCard(
                        icon: "face.smiling",
                        title: String(localized: "home_mood_check", defaultValue: "Mood Check"),
                        subtitle: String(localized: "home_mood_check_sub", defaultValue: "How are you feeling right now?"),
                        color: .primaryPurple,
                        destination: MoodCheckView()
                    )

                    ActionCard(
                        icon: "brain.head.profile",
                        title: String(localized: "home_thought_unwinder", defaultValue: "Thought Unwinder"),
                        subtitle: String(localized: "home_thought_unwinder_sub", defaultValue: "Explore and reframe a thought"),
                        color: .secondaryLavender,
                        destination: ThoughtUnwinderView()
                    )

                    ActionCard(
                        icon: "wind",
                        title: String(localized: "home_breathing", defaultValue: "Breathing Exercise"),
                        subtitle: String(localized: "home_breathing_sub", defaultValue: "Take a moment to breathe"),
                        color: .successGreen,
                        destination: BreathingView()
                    )

                    ActionCard(
                        icon: "lightbulb",
                        title: String(localized: "home_thought_traps", defaultValue: "Thought Traps"),
                        subtitle: String(localized: "home_thought_traps_sub", defaultValue: "Learn about common thinking patterns"),
                        color: .twistyOrange,
                        destination: ThoughtTrapsListView()
                    )

                    ActionCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: String(localized: "home_insights", defaultValue: "Insights"),
                        subtitle: String(localized: "home_insights_sub", defaultValue: "See your progress and trends"),
                        color: .successGreen,
                        destination: InsightsView()
                    )
                }
                .padding(.horizontal)
            }
        }
        .background(Color.appBackground)
        .fullScreenCover(isPresented: $showUnwinding) {
            NavigationStack {
                UnwindingNowView()
            }
        }
        .navigationTitle(String(localized: "app_name", defaultValue: "Untwist"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }
}

// MARK: - Action Card

struct ActionCard<Destination: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let destination: Destination

    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.textPrimary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            .padding()
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
