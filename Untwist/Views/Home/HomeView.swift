import SwiftUI

struct HomeView: View {
    @State private var showUnwinding = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                headerCard
                unwindHeroCard
                sectionTitle
                quickActionGrid
                insightsCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .background(backgroundLayer)
        .fullScreenCover(isPresented: $showUnwinding) {
            NavigationStack {
                UnwindingNowView()
            }
        }
        .navigationTitle(String(localized: "app_name", defaultValue: "Untwist"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    LazyView { SettingsView() }
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appBackground, Color.primaryPurple.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.twistyOrange.opacity(0.20))
                .frame(width: 260, height: 260)
                .blur(radius: 55)
                .offset(x: 150, y: -260)

            Circle()
                .fill(Color.primaryPurple.opacity(0.16))
                .frame(width: 280, height: 280)
                .blur(radius: 70)
                .offset(x: -140, y: -140)
        }
        .ignoresSafeArea()
    }

    private var headerCard: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(String(localized: "home_greeting", defaultValue: "Hey there! How are you today?"))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.leading)

                Text(todayLabel)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.8)
            }

            Spacer(minLength: 0)

            TwistyView(mood: .happy, size: 78)
                .frame(width: 88, height: 88)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.primaryPurple.opacity(0.10))
                )
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.cardBackground.opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.primaryPurple.opacity(0.14), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 14, y: 5)
    }

    private var unwindHeroCard: some View {
        Button {
            showUnwinding = true
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Text(String(localized: "home_unwinding_now", defaultValue: "Unwinding Now"))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.textPrimary)

                    Spacer()

                    Image(systemName: "bolt.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.primaryPurple)
                        .padding(8)
                        .background(Color.cardBackground.opacity(0.7), in: Circle())
                }

                Text(String(localized: "home_unwinding_now_sub", defaultValue: "Feeling overwhelmed?"))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)

                HStack(spacing: 10) {
                    TwistyView(mood: .breathing, size: 48, animated: false)

                    Text(String(localized: "home_unwinding_now_hint", defaultValue: "A short guided reset in under 2 minutes"))
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(2)

                    Spacer()

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.primaryPurple)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.twistyOrange.opacity(0.34), Color.primaryPurple.opacity(0.24)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.primaryPurple.opacity(0.20), lineWidth: 1)
            )
            .shadow(color: Color.primaryPurple.opacity(0.14), radius: 16, y: 6)
        }
        .buttonStyle(.plain)
    }

    private var sectionTitle: some View {
        HStack {
            Text(String(localized: "home_practice_title", defaultValue: "Daily Practice"))
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
            Spacer()
        }
    }

    private var quickActionGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            HomeActionCard(
                icon: "face.smiling",
                title: String(localized: "home_mood_check", defaultValue: "Mood Check"),
                subtitle: String(localized: "home_mood_check_sub", defaultValue: "How are you feeling right now?"),
                color: .primaryPurple
            ) { MoodCheckView() }

            HomeActionCard(
                icon: "brain.head.profile",
                title: String(localized: "home_thought_unwinder", defaultValue: "Thought Unwinder"),
                subtitle: String(localized: "home_thought_unwinder_sub", defaultValue: "Explore and reframe a thought"),
                color: .secondaryLavender
            ) { ThoughtUnwinderView() }

            HomeActionCard(
                icon: "wind",
                title: String(localized: "home_breathing", defaultValue: "Breathing Exercise"),
                subtitle: String(localized: "home_breathing_sub", defaultValue: "Take a moment to breathe"),
                color: .successGreen
            ) { BreathingView() }

            HomeActionCard(
                icon: "lightbulb",
                title: String(localized: "home_thought_traps", defaultValue: "Thought Traps"),
                subtitle: String(localized: "home_thought_traps_sub", defaultValue: "Learn about common thinking patterns"),
                color: .twistyOrange
            ) { ThoughtTrapsListView() }
        }
    }

    private var insightsCard: some View {
        NavigationLink {
            LazyView { InsightsView() }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundStyle(Color.successGreen)
                    .frame(width: 48, height: 48)
                    .background(Color.successGreen.opacity(0.14), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(String(localized: "home_insights", defaultValue: "Insights"))
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                    Text(String(localized: "home_insights_sub", defaultValue: "See your progress and trends"))
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.cardBackground.opacity(0.96))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.successGreen.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var todayLabel: String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEE d MMM")
        return formatter.string(from: Date())
    }

    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
    }
}

// MARK: - Action Card

struct HomeActionCard<Destination: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(color)
                    .frame(width: 42, height: 42)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(2)

                Spacer(minLength: 0)

                HStack {
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                        .foregroundStyle(color.opacity(0.9))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 156, alignment: .topLeading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.cardBackground.opacity(0.96))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(color.opacity(0.16), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Lazy View Helper

private struct LazyView<Content: View>: View {
    let build: () -> Content

    init(@ViewBuilder _ build: @escaping () -> Content) {
        self.build = build
    }

    var body: some View {
        build()
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
