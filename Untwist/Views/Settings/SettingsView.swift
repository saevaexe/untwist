import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("notificationEnabled") private var notificationEnabled = false
    @AppStorage("notificationHour") private var notificationHour = 9
    @AppStorage("notificationMinute") private var notificationMinute = 0
    @AppStorage("preferredTheme") private var preferredTheme = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var showDeleteAlert = false
    private let notificationManager = NotificationManager.shared

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.hour = notificationHour
                components.minute = notificationMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newValue in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                notificationHour = components.hour ?? 9
                notificationMinute = components.minute ?? 0
                if notificationEnabled {
                    notificationManager.scheduleDailyReminder(hour: notificationHour, minute: notificationMinute)
                }
            }
        )
    }

    var body: some View {
        List {
            // Notifications
            Section {
                Toggle(String(localized: "settings_notifications", defaultValue: "Daily Reminder"), isOn: $notificationEnabled)
                    .onChange(of: notificationEnabled) { _, enabled in
                        if enabled {
                            Task {
                                let granted = await notificationManager.requestPermission()
                                if granted {
                                    notificationManager.scheduleDailyReminder(hour: notificationHour, minute: notificationMinute)
                                } else {
                                    notificationEnabled = false
                                }
                            }
                        } else {
                            notificationManager.cancelDailyReminder()
                        }
                    }

                if notificationEnabled {
                    DatePicker(
                        String(localized: "settings_notif_time", defaultValue: "Reminder Time"),
                        selection: reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                }
            } header: {
                Text(String(localized: "settings_notifications_header", defaultValue: "Notifications"))
            }

            // Appearance
            Section {
                Picker(String(localized: "settings_theme", defaultValue: "Theme"), selection: $preferredTheme) {
                    Text(String(localized: "settings_theme_system", defaultValue: "System")).tag(0)
                    Text(String(localized: "settings_theme_light", defaultValue: "Light")).tag(1)
                    Text(String(localized: "settings_theme_dark", defaultValue: "Dark")).tag(2)
                }
            } header: {
                Text(String(localized: "settings_appearance_header", defaultValue: "Appearance"))
            }

            // Data
            Section {
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label(String(localized: "settings_delete_data", defaultValue: "Delete All Data"), systemImage: "trash")
                }
            } header: {
                Text(String(localized: "settings_data_header", defaultValue: "Data"))
            } footer: {
                Text(String(localized: "settings_data_footer", defaultValue: "All your data is stored only on this device."))
            }

            // About
            Section {
                NavigationLink {
                    DisclaimerView()
                } label: {
                    Label(String(localized: "settings_disclaimer", defaultValue: "Disclaimer"), systemImage: "info.circle")
                }

                NavigationLink {
                    CrisisView()
                } label: {
                    Label(String(localized: "settings_emergency", defaultValue: "Emergency Contacts"), systemImage: "heart")
                }

                HStack {
                    Text(String(localized: "settings_version", defaultValue: "Version"))
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .foregroundStyle(Color.textSecondary)
                }
            } header: {
                Text(String(localized: "settings_about_header", defaultValue: "About"))
            }
        }
        .navigationTitle(String(localized: "settings_title", defaultValue: "Settings"))
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task {
                await notificationManager.checkAuthorization()
                // Sync toggle: if permission was revoked in iOS Settings, turn off
                if notificationEnabled && !notificationManager.isAuthorized {
                    notificationEnabled = false
                }
                // Sync toggle: if permission was granted in iOS Settings after redirect
                if !notificationEnabled && notificationManager.isAuthorized && !notificationManager.isDenied {
                    // Don't auto-enable — let user toggle manually
                }
            }
        }
        .alert(String(localized: "settings_delete_title", defaultValue: "Delete All Data?"), isPresented: $showDeleteAlert) {
            Button(String(localized: "settings_cancel", defaultValue: "Cancel"), role: .cancel) {}
            Button(String(localized: "settings_delete_confirm", defaultValue: "Delete"), role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text(String(localized: "settings_delete_message", defaultValue: "This will permanently delete all your mood entries, thought records, and breathing sessions. This cannot be undone."))
        }
    }

    private func deleteAllData() {
        try? modelContext.delete(model: MoodEntry.self)
        try? modelContext.delete(model: ThoughtRecord.self)
        try? modelContext.delete(model: BreathingSession.self)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: [MoodEntry.self, ThoughtRecord.self, BreathingSession.self], inMemory: true)
}
