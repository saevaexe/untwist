import Foundation
import RevenueCat

final class AnalyticsManager {
    static let shared = AnalyticsManager()

    private init() {}

    private var iso8601Now: String {
        ISO8601DateFormatter().string(from: Date())
    }

    func trackOnboardingCompleted() {
        Purchases.shared.attribution.setAttributes([
            "$onboardingCompleted": iso8601Now
        ])
    }

    func trackFirstMoodEntry() {
        Purchases.shared.attribution.setAttributes([
            "$firstMoodEntry": iso8601Now
        ])
    }

    func trackFirstThoughtRecord() {
        Purchases.shared.attribution.setAttributes([
            "$firstThoughtRecord": iso8601Now
        ])
    }

    func trackFirstBreathingSession() {
        Purchases.shared.attribution.setAttributes([
            "$firstBreathingSession": iso8601Now
        ])
    }

    func trackFirstInsightsView() {
        Purchases.shared.attribution.setAttributes([
            "$firstInsightsView": iso8601Now
        ])
    }

    func trackPaywallShown() {
        Purchases.shared.attribution.setAttributes([
            "$lastPaywallShown": iso8601Now
        ])
    }
}
