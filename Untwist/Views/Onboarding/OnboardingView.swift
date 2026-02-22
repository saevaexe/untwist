import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                // Page 1: Welcome + Twisty
                VStack(spacing: 24) {
                    Spacer()

                    TwistyView(mood: .waving, size: 200)

                    Text(String(localized: "onboarding_welcome_title", defaultValue: "Meet Twisty"))
                        .font(.title.weight(.bold))
                        .foregroundStyle(Color.textPrimary)

                    Text(String(localized: "onboarding_welcome_sub", defaultValue: "Your companion for understanding your thoughts better. Together, we'll learn to spot thinking patterns."))
                        .font(.body)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Spacer()
                    Spacer()
                }
                .tag(0)

                // Page 2: How it works
                VStack(spacing: 24) {
                    Spacer()

                    Image("OnboardingWorkflow")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 220)

                    Text(String(localized: "onboarding_how_title", defaultValue: "How it works"))
                        .font(.title.weight(.bold))
                        .foregroundStyle(Color.textPrimary)

                    Text(String(localized: "onboarding_how_sub", defaultValue: "Track your mood, explore your thoughts, and discover healthier ways to see things. All in under 2 minutes."))
                        .font(.body)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Spacer()
                    Spacer()
                }
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

    private var disclaimerPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image("OnboardingShield")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120)

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
