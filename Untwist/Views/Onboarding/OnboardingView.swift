import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var isCompleting = false

    var body: some View {
        ZStack {
            AppScreenBackground(
                primaryTint: Color.primaryPurple.opacity(0.15),
                secondaryTint: Color.twistyOrange.opacity(0.18),
                tertiaryTint: Color.successGreen.opacity(0.10)
            )

            VStack(spacing: 16) {
                progressHeader

                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    workflowPage.tag(1)
                    disclaimerPage.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.28), value: currentPage)

                bottomBar
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 26)
        }
    }

    private var progressHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "app_name", defaultValue: "Untwist"))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(currentPageTitle)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Text("\(currentPage + 1)/3")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.primaryPurple)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.primaryPurple.opacity(0.16), in: Capsule(style: .continuous))
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule(style: .continuous)
                        .fill(index == currentPage ? Color.primaryPurple : Color.primaryPurple.opacity(0.26))
                        .frame(width: index == currentPage ? 30 : 8, height: 8)
                        .animation(.spring(response: 0.26, dampingFraction: 0.86), value: currentPage)
                }
            }

            Button {
                handlePrimaryAction()
            } label: {
                HStack(spacing: 10) {
                    Text(buttonTitle)
                        .font(.headline)
                    if isCompleting {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.primaryPurple, Color.secondaryLavender, Color.primaryPurple.opacity(0.95)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.18), lineWidth: 1)
                )
            }
            .disabled(isCompleting)
            .opacity(isCompleting ? 0.8 : 1)
            .shadow(color: Color.primaryPurple.opacity(0.26), radius: 14, y: 6)
        }
    }

    private var buttonTitle: String {
        currentPage == 2
            ? String(localized: "onboarding_get_started", defaultValue: "Get Started")
            : String(localized: "unwinder_next", defaultValue: "Next")
    }

    private var currentPageTitle: String {
        switch currentPage {
        case 0:
            String(localized: "onboarding_welcome_title", defaultValue: "Meet Twisty")
        case 1:
            String(localized: "onboarding_how_title", defaultValue: "How it works")
        default:
            String(localized: "onboarding_disclaimer_title", defaultValue: "Important")
        }
    }

    private var welcomePage: some View {
        onboardingCard(stroke: Color.primaryPurple.opacity(0.18)) {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.primaryPurple.opacity(0.12))
                        .frame(width: 196, height: 196)

                    Circle()
                        .stroke(Color.primaryPurple.opacity(0.24), lineWidth: 1)
                        .frame(width: 196, height: 196)

                    TwistyView(mood: .waving, size: 168)
                }
                .padding(.top, 8)

                Text(String(localized: "onboarding_welcome_title", defaultValue: "Meet Twisty"))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                    .minimumScaleFactor(0.78)
                    .lineLimit(1)

                Text(String(localized: "onboarding_welcome_sub", defaultValue: "Your companion for understanding your thoughts better. Together, we'll learn to spot thinking patterns."))
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                Spacer(minLength: 12)
            }
        }
    }

    private var workflowPage: some View {
        onboardingCard(stroke: Color.secondaryLavender.opacity(0.24)) {
            VStack(spacing: 16) {
                workflowGraphic
                    .padding(.top, 4)

                Text(String(localized: "onboarding_how_title", defaultValue: "How it works"))
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.textPrimary)

                Text(String(localized: "onboarding_how_sub", defaultValue: "Track your mood, explore your thoughts, and discover healthier ways to see things. All in under 2 minutes."))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 10) {
                    onboardingStepRow(
                        icon: "heart.text.square.fill",
                        title: String(localized: "home_mood_check", defaultValue: "Mood Check"),
                        subtitle: String(localized: "home_mood_check_sub", defaultValue: "How are you feeling right now?"),
                        tint: .primaryPurple
                    )

                    onboardingStepRow(
                        icon: "brain.head.profile",
                        title: String(localized: "home_thought_unwinder", defaultValue: "Thought Unwinder"),
                        subtitle: String(localized: "home_thought_unwinder_sub", defaultValue: "Explore and reframe a thought"),
                        tint: .secondaryLavender
                    )

                    onboardingStepRow(
                        icon: "wind",
                        title: String(localized: "home_breathing", defaultValue: "Breathing Exercise"),
                        subtitle: String(localized: "home_breathing_sub", defaultValue: "Take a moment to breathe"),
                        tint: .successGreen
                    )
                }

                Spacer(minLength: 8)
            }
        }
    }

    private var disclaimerPage: some View {
        onboardingCard(stroke: Color.successGreen.opacity(0.26)) {
            VStack(spacing: 18) {
                shieldGraphic
                    .padding(.top, 8)

                Text(String(localized: "onboarding_disclaimer_title", defaultValue: "Important"))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                    .minimumScaleFactor(0.80)
                    .lineLimit(1)

                Text(String(localized: "onboarding_disclaimer_body", defaultValue: "Untwist is a self-help tool based on CBT principles. It is not a substitute for professional therapy or medical advice. If you're in crisis, please contact a mental health professional or call emergency services."))
                    .font(.callout.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 8)

                Text(String(localized: "onboarding_privacy_note", defaultValue: "Your data stays on your device. We don't collect or share any personal information."))
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.successGreen.opacity(0.14))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.successGreen.opacity(0.26), lineWidth: 1)
                    )

                Spacer(minLength: 8)
            }
        }
    }

    private var workflowGraphic: some View {
        HStack(spacing: 12) {
            flowIcon("heart.text.square.fill", tint: .primaryPurple)
            Image(systemName: "arrow.right")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.textSecondary)
            flowIcon("brain.head.profile", tint: .secondaryLavender)
            Image(systemName: "arrow.right")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.textSecondary)
            flowIcon("lightbulb.fill", tint: .twistyOrange)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.appBackground.opacity(0.90))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.secondaryLavender.opacity(0.22), lineWidth: 1)
        )
    }

    private func flowIcon(_ icon: String, tint: Color) -> some View {
        Image(systemName: icon)
            .font(.title3.weight(.semibold))
            .foregroundStyle(tint)
            .frame(width: 52, height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(tint.opacity(0.14))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(tint.opacity(0.24), lineWidth: 1)
            )
    }

    private var shieldGraphic: some View {
        ZStack {
            Circle()
                .fill(Color.successGreen.opacity(0.16))
                .frame(width: 126, height: 126)

            Circle()
                .stroke(Color.successGreen.opacity(0.24), lineWidth: 1)
                .frame(width: 126, height: 126)

            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 52, weight: .bold))
                .foregroundStyle(Color.primaryPurple)
        }
    }

    private func onboardingStepRow(icon: String, title: String, subtitle: String, tint: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(tint.opacity(0.16), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(subtitle)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.appBackground.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(tint.opacity(0.18), lineWidth: 1)
        )
    }

    private func onboardingCard(stroke: Color, @ViewBuilder content: () -> some View) -> some View {
        VStack {
            content()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 22)
        .padding(.vertical, 24)
        .elevatedCard(stroke: stroke, shadowColor: .black.opacity(0.10))
    }

    private func handlePrimaryAction() {
        guard !isCompleting else { return }

        if currentPage < 2 {
            withAnimation { currentPage += 1 }
            return
        }

        isCompleting = true
        Task {
            _ = await NotificationManager.shared.requestPermission()
            await MainActor.run {
                hasCompletedOnboarding = true
                isCompleting = false
            }
        }
    }
}

#Preview {
    OnboardingView()
}
