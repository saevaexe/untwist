import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("onboardingFlowVersion") private var onboardingFlowVersion = 0
    @AppStorage("preferredTheme") private var preferredTheme = 0
    private let requiredOnboardingFlowVersion = 2

    private var shouldShowOnboarding: Bool {
        !hasCompletedOnboarding || onboardingFlowVersion < requiredOnboardingFlowVersion
    }

    private var colorScheme: ColorScheme? {
        switch preferredTheme {
        case 1: .light
        case 2: .dark
        default: nil
        }
    }

    var body: some View {
        Group {
            if shouldShowOnboarding {
                OnboardingView()
            } else {
                NavigationStack {
                    HomeView()
                }
            }
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [MoodEntry.self, ThoughtRecord.self, BreathingSession.self], inMemory: true)
}
