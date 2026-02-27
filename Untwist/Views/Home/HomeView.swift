import SwiftUI

struct HomeView: View {
    @AppStorage("launchThoughtWriterAfterOnboarding") private var launchThoughtWriterAfterOnboarding = false
    @State private var showUnwinding = false
    @State private var showThoughtWriter = false
    @State private var showCrisis = false
    @State private var moodCheckRequest: MoodCheckRequest?

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    heroSection
                    unwindHeroCard
                    sectionTitle
                    quickActionGrid
                    insightsCard
                }
                .padding(.horizontal, 20)
                .padding(.top, -8)
                .padding(.bottom, 120)
            }

            // Crisis floating button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showCrisis = true
                    } label: {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(Color.crisisWarning)
                            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                    }
                    .accessibilityLabel(String(localized: "crisis_button", defaultValue: "Emergency Help"))
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(backgroundLayer)
        .fullScreenCover(isPresented: $showUnwinding) {
            NavigationStack {
                UnwindingNowView()
            }
        }
        .fullScreenCover(isPresented: $showThoughtWriter) {
            NavigationStack {
                ThoughtUnwinderView()
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(String(localized: "onboarding_close_unwinder", defaultValue: "Close")) {
                                showThoughtWriter = false
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.textSecondary)
                        }
                    }
            }
        }
        .fullScreenCover(isPresented: $showCrisis) {
            CrisisView()
        }
        .sheet(item: $moodCheckRequest) { request in
            NavigationStack {
                MoodCheckView(initialScore: request.initialScore)
                    .id(request.id)
            }
        }
        .onAppear {
            guard launchThoughtWriterAfterOnboarding else { return }
            launchThoughtWriterAfterOnboarding = false
            DispatchQueue.main.async {
                showThoughtWriter = true
            }
        }
        .onChange(of: showThoughtWriter) {
            guard !showThoughtWriter else { return }
        }
        .toolbar(.hidden, for: .navigationBar)
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

    private var heroSection: some View {
        VStack(spacing: 1) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(greetingText)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)

                    Text(todayLabel)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.75))
                        .textCase(.uppercase)
                        .tracking(0.8)
                }
                Spacer()

                NavigationLink {
                    LazyView { SettingsView() }
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.primaryPurple)
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.88), in: Circle())
                }
                .accessibilityLabel(String(localized: "settings_title", defaultValue: "Settings"))
            }

            TwistyView(mood: .happy, size: 116)
                .offset(y: -12)

            Text(String(localized: "home_mood_check_sub", defaultValue: "How are you feeling today?"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.92))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, -27)

            // Quick mood answer row
            HStack(spacing: 8) {
                quickMoodButton(mood: .sad, label: String(localized: "home_mood_awful", defaultValue: "Very Bad"), score: 10)
                quickMoodButton(mood: .neutral, label: String(localized: "home_mood_low", defaultValue: "Bad"), score: 30)
                quickMoodButton(mood: .calm, label: String(localized: "home_mood_okay", defaultValue: "Okay"), score: 50)
                quickMoodButton(mood: .happy, label: String(localized: "home_mood_good", defaultValue: "Good"), score: 70)
                quickMoodButton(mood: .celebrating, label: String(localized: "home_mood_great", defaultValue: "Great"), score: 90)
            }
            .padding(.top, -4)
        }
        .padding(.horizontal, 16)
        .padding(.top, 5)
        .padding(.bottom, 9)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.primaryPurple.opacity(0.85), Color.twistyOrange.opacity(0.65)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: Color.primaryPurple.opacity(0.20), radius: 16, y: 6)
    }

    private func quickMoodButton(mood: TwistyMood, label: String, score: Int) -> some View {
        Button {
            guard moodCheckRequest == nil else { return }
            moodCheckRequest = MoodCheckRequest(initialScore: Double(score))
        } label: {
            VStack(spacing: 3) {
                Image(mood.imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(5)
                    .frame(width: 62, height: 62)
                    .background(.white.opacity(0.20), in: Circle())

                Text(label)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel(label)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return String(localized: "home_greeting_morning", defaultValue: "Good Morning!")
        case 12..<17:
            return String(localized: "home_greeting_afternoon", defaultValue: "Good Afternoon!")
        case 17..<22:
            return String(localized: "home_greeting_evening", defaultValue: "Good Evening!")
        default:
            return String(localized: "home_greeting_night", defaultValue: "Good Night!")
        }
    }

    private var unwindHeroCard: some View {
        Button {
            showUnwinding = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "bolt.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.primaryPurple.opacity(0.8), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "home_unwinding_now", defaultValue: "Unwinding Now"))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.textPrimary)

                    Text(String(localized: "home_unwinding_now_hint", defaultValue: "A short guided reset in under 2 minutes"))
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.primaryPurple)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.twistyOrange.opacity(0.20), Color.primaryPurple.opacity(0.14)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.primaryPurple.opacity(0.16), lineWidth: 1)
            )
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
                subtitle: String(localized: "home_mood_check_sub", defaultValue: "How are you feeling today?"),
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

    private struct MoodCheckRequest: Identifiable {
        let id = UUID()
        let initialScore: Double
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
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: icon)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(color)
                        .frame(width: 38, height: 38)
                        .background(color.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    Spacer()

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                        .foregroundStyle(color.opacity(0.9))
                }

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(2)
                    .frame(minHeight: 32, alignment: .top)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(12)
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
