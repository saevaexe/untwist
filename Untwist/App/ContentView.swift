import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("preferredTheme") private var preferredTheme = 0
    private var colorScheme: ColorScheme? {
        switch preferredTheme {
        case 1: .light
        case 2: .dark
        default: nil
        }
    }

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                NavigationStack {
                    HomeView()
                }
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [MoodEntry.self, ThoughtRecord.self, BreathingSession.self], inMemory: true)
}
