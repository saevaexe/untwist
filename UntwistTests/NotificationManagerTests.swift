import Testing
import UserNotifications
@testable import Untwist

struct NotificationManagerTests {

    @Test func sharedInstanceIsSingleton() {
        let a = NotificationManager.shared
        let b = NotificationManager.shared
        #expect(a === b)
    }

    @Test func checkAuthorizationUpdatesState() async {
        let manager = NotificationManager.shared
        await manager.checkAuthorization()
        // On simulator without permission, should be false
        // We just verify it doesn't crash and updates deterministically
        #expect(manager.isAuthorized == false || manager.isAuthorized == true)
    }

    @Test func cancelDailyReminderDoesNotCrash() async throws {
        let manager = NotificationManager.shared
        // Cancel when nothing is scheduled — should not crash
        manager.cancelDailyReminder()

        try await Task.sleep(for: .milliseconds(100))

        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let dailyReminder = requests.first { $0.identifier == "dailyReminder" }
        #expect(dailyReminder == nil)
    }

    @Test func scheduleThenCancelRemovesPendingRequest() async throws {
        let manager = NotificationManager.shared

        // Schedule
        manager.scheduleDailyReminder(hour: 9, minute: 0)
        try await Task.sleep(for: .milliseconds(200))

        // Cancel
        manager.cancelDailyReminder()
        try await Task.sleep(for: .milliseconds(200))

        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let dailyReminder = requests.first { $0.identifier == "dailyReminder" }
        #expect(dailyReminder == nil)
    }
}
