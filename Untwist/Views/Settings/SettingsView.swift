import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("notificationEnabled") private var notificationEnabled = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteAlert = false

    var body: some View {
        List {
            // Notifications
            Section {
                Toggle(String(localized: "settings_notifications", defaultValue: "Daily Reminder"), isOn: $notificationEnabled)
            } header: {
                Text(String(localized: "settings_notifications_header", defaultValue: "Notifications"))
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
