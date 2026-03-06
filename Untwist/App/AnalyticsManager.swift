import Foundation
import RevenueCat

final class AnalyticsManager {
    static let shared = AnalyticsManager()

    private init() {}

    private var iso8601Now: String {
        ISO8601DateFormatter().string(from: Date())
    }

    private func setAttributes(_ attributes: [String: String]) {
        guard Purchases.isConfigured else { return }
        Purchases.shared.attribution.setAttributes(attributes)
    }

    // MARK: - One-Time Milestones

    func trackOnboardingCompleted() {
        setAttributes(["$onboardingCompleted": iso8601Now])
    }

    func trackFirstMoodEntry() {
        setAttributes(["$firstMoodEntry": iso8601Now])
    }

    func trackFirstThoughtRecord() {
        setAttributes(["$firstThoughtRecord": iso8601Now])
    }

    func trackFirstBreathingSession() {
        setAttributes(["$firstBreathingSession": iso8601Now])
    }

    func trackFirstInsightsView() {
        setAttributes(["$firstInsightsView": iso8601Now])
    }

    func trackPaywallShown() {
        setAttributes(["$lastPaywallShown": iso8601Now])
    }

    // MARK: - Cumulative Counters

    func incrementMoodEntries() {
        let key = "totalMoodEntries"
        let count = UserDefaults.standard.integer(forKey: key) + 1
        UserDefaults.standard.set(count, forKey: key)
        setAttributes([
            "$totalMoodEntries": "\(count)",
            "$lastActiveDate": iso8601Now
        ])
    }

    func incrementThoughtRecords() {
        let key = "totalThoughtRecords"
        let count = UserDefaults.standard.integer(forKey: key) + 1
        UserDefaults.standard.set(count, forKey: key)
        setAttributes([
            "$totalThoughtRecords": "\(count)",
            "$lastActiveDate": iso8601Now
        ])
    }

    func incrementBreathingSessions() {
        let key = "totalBreathingSessions"
        let count = UserDefaults.standard.integer(forKey: key) + 1
        UserDefaults.standard.set(count, forKey: key)
        setAttributes([
            "$totalBreathingSessions": "\(count)",
            "$lastActiveDate": iso8601Now
        ])
    }

    // MARK: - App Lifecycle

    func updateAppLaunchAttributes() {
        let installKey = "firstInstallDate"
        if UserDefaults.standard.object(forKey: installKey) == nil {
            UserDefaults.standard.set(Date(), forKey: installKey)
        }

        let installDate = UserDefaults.standard.object(forKey: installKey) as? Date ?? Date()
        let daysSince = max(0, Int(Date().timeIntervalSince(installDate) / 86400))

        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let language = Locale.preferredLanguages.first ?? "unknown"

        setAttributes([
            "$daysSinceInstall": "\(daysSince)",
            "$appVersion": version,
            "$preferredLanguage": language
        ])
    }

    // MARK: - Subscription Events

    func trackSubscriptionEvent(_ event: String) {
        setAttributes([
            "$lastSubscriptionEvent": event,
            "$lastSubscriptionEventDate": iso8601Now
        ])
    }
}
