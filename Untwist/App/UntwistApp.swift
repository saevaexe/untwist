import SwiftUI
import SwiftData

@main
struct UntwistApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            MoodEntry.self,
            ThoughtRecord.self,
            BreathingSession.self
        ])
    }
}
