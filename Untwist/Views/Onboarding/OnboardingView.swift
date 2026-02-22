import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                // Page 1: Welcome + Twisty
                onboardingPage(
                    icon: "circle.fill",
                    iconColor: .twistyOrange,
                    title: String(localized: "onboarding_welcome_title", defaultValue: "Meet Twisty"),
                    subtitle: String(localized: "onboarding_welcome_sub", defaultValue: "Your companion for understanding your thoughts better. Together, we'll learn to spot thinking patterns.")
                )
                .tag(0)

                // Page 2: How it works
                onboardingPage(
                    icon: "brain.head.profile",
                    iconColor: .primaryPurple,
                    title: String(localized: "onboarding_how_title", defaultValue: "How it works"),
                    subtitle: String(localized: "onboarding_how_sub", defaultValue: "Track your mood, explore your thoughts, and discover healthier ways to see things. All in under 2 minutes.")
                )
                .tag(1)

                // Page 3: Disclaimer + Get Started
                disclaimerPage
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.easeInOut, value: currentPage)
        }
        .background(Color.appBackground)
    }

    private func onboardingPage(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundStyle(iconColor)

            Text(title)
                .font(.title.weight(.bold))
                .foregroundStyle(Color.textPrimary)

            Text(subtitle)
                .font(.body)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }

    private var disclaimerPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "shield.checkered")
                .font(.system(size: 60))
                .foregroundStyle(Color.primaryPurple)

            Text(String(localized: "onboarding_disclaimer_title", defaultValue: "Important"))
                .font(.title.weight(.bold))
                .foregroundStyle(Color.textPrimary)

            Text(String(localized: "onboarding_disclaimer_body", defaultValue: "Untwist is a self-help tool based on CBT principles. It is not a substitute for professional therapy or medical advice. If you're in crisis, please contact a mental health professional or call emergency services."))
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Text(String(localized: "onboarding_privacy_note", defaultValue: "Your data stays on your device. We don't collect or share any personal information."))
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button {
                hasCompletedOnboarding = true
            } label: {
                Text(String(localized: "onboarding_get_started", defaultValue: "Get Started"))
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryPurple)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    OnboardingView()
}
