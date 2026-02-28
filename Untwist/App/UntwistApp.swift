import SwiftUI
import SwiftData

@main
struct UntwistApp: App {
    @State private var subscriptionManager = SubscriptionManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(subscriptionManager)
                .task {
                    subscriptionManager.configure()
                    await subscriptionManager.checkSubscriptionStatus()
                }
        }
        .modelContainer(for: [
            MoodEntry.self,
            ThoughtRecord.self,
            BreathingSession.self
        ])
    }
}
