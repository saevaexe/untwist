import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("preferredTheme") private var preferredTheme = 0
    @State private var showCrisis = false

    private var colorScheme: ColorScheme? {
        switch preferredTheme {
        case 1: .light
        case 2: .dark
        default: nil
        }
    }

    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                NavigationStack {
                    HomeView()
                }
            } else {
                OnboardingView()
            }

            // Crisis floating button — accessible from every screen
            if hasCompletedOnboarding {
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
        }
        .fullScreenCover(isPresented: $showCrisis) {
            CrisisView()
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [MoodEntry.self, ThoughtRecord.self, BreathingSession.self], inMemory: true)
}
