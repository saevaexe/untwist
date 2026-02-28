import Foundation
import RevenueCat

enum AnalyticsManager {
    static func trackMilestone(_ milestone: Milestone) {
        let now = ISO8601DateFormatter().string(from: Date())
        Purchases.shared.attribution.setAttributes([
            milestone.rawValue: now
        ])
    }

    static func setUserProperty(_ key: String, value: String) {
        Purchases.shared.attribution.setAttributes([key: value])
    }

    enum Milestone: String {
        case onboardingCompleted = "onboarding_completed_at"
        case firstMoodCheck = "first_mood_check_at"
        case firstThoughtRecord = "first_thought_record_at"
        case firstBreathingSession = "first_breathing_at"
        case insightsViewed = "insights_viewed_at"
        case crisisScreenOpened = "crisis_opened_at"
    }
}
