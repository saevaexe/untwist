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
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var showDeleteAlert = false
    @State private var showPaywall = false
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
        ZStack {
            AppScreenBackground(
                primaryTint: Color.primaryPurple.opacity(0.15),
                secondaryTint: Color.secondaryLavender.opacity(0.16),
                tertiaryTint: Color.successGreen.opacity(0.10)
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    headerCard
                    subscriptionCard
                    notificationsCard
                    appearanceCard
                    dataCard
                    aboutCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 120)
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
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
                .environment(subscriptionManager)
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

    private var headerCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "settings_title", defaultValue: "Settings"))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)

                Text(String(localized: "settings_data_footer", defaultValue: "All your data is stored only on this device."))
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer(minLength: 0)

            Image(systemName: "gearshape.fill")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.primaryPurple)
                .frame(width: 42, height: 42)
                .background(Color.primaryPurple.opacity(0.14), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(16)
        .elevatedCard(stroke: Color.primaryPurple.opacity(0.16), shadowColor: .black.opacity(0.07))
    }

    private var subscriptionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel(
                title: String(localized: "settings_subscription_header", defaultValue: "Subscription"),
                icon: "crown.fill",
                tint: .primaryPurple
            )

            if subscriptionManager.hasFullAccess {
                if subscriptionManager.isTrialActive {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(localized: "settings_trial_active", defaultValue: "Free Trial Active"))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.textPrimary)

                            Text(String(
                                format: String(localized: "settings_trial_remaining %lld", defaultValue: "%lld days remaining"),
                                Int64(subscriptionManager.trialDaysRemaining)
                            ))
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                        }
                        Spacer()
                        manageSubscriptionLink
                    }
                } else {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(Color.primaryPurple)
                            Text(String(localized: "settings_pro_member", defaultValue: "Pro Member"))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.textPrimary)
                        }
                        Spacer()
                        manageSubscriptionLink
                    }
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Text(String(localized: "settings_upgrade_now", defaultValue: "Upgrade to Pro"))
                            .font(.subheadline.weight(.bold))
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title3)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color.primaryPurple, Color.primaryPurple.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .elevatedCard(stroke: Color.primaryPurple.opacity(0.20))
    }

    private var manageSubscriptionLink: some View {
        Link(destination: URL(string: "https://apps.apple.com/account/subscriptions")!) {
            Text(String(localized: "settings_manage", defaultValue: "Manage"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.primaryPurple)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.primaryPurple.opacity(0.12), in: Capsule())
        }
    }

    private var notificationsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel(
                title: String(localized: "settings_notifications_header", defaultValue: "Notifications"),
                icon: "bell.badge.fill",
                tint: .primaryPurple
            )

            Toggle(String(localized: "settings_notifications", defaultValue: "Daily Reminder"), isOn: $notificationEnabled)
                .tint(Color.primaryPurple)
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
                Divider()
                    .overlay(Color.primaryPurple.opacity(0.16))

                HStack(spacing: 10) {
                    Text(String(localized: "settings_notif_time", defaultValue: "Reminder Time"))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.textPrimary)

                    Spacer()

                    DatePicker(
                        "",
                        selection: reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(Color.primaryPurple)
                }
            }
        }
        .padding(18)
        .elevatedCard(stroke: Color.primaryPurple.opacity(0.18))
    }

    private var appearanceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel(
                title: String(localized: "settings_appearance_header", defaultValue: "Appearance"),
                icon: "circle.lefthalf.filled",
                tint: .secondaryLavender
            )

            Picker(String(localized: "settings_theme", defaultValue: "Theme"), selection: $preferredTheme) {
                Text(String(localized: "settings_theme_system", defaultValue: "System")).tag(0)
                Text(String(localized: "settings_theme_light", defaultValue: "Light")).tag(1)
                Text(String(localized: "settings_theme_dark", defaultValue: "Dark")).tag(2)
            }
            .pickerStyle(.segmented)
        }
        .padding(18)
        .elevatedCard(stroke: Color.secondaryLavender.opacity(0.22))
    }

    private var dataCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel(
                title: String(localized: "settings_data_header", defaultValue: "Data"),
                icon: "externaldrive.fill",
                tint: .twistyOrange
            )

            Text(String(localized: "settings_data_footer", defaultValue: "All your data is stored only on this device."))
                .font(.footnote)
                .foregroundStyle(Color.textSecondary)

            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text(String(localized: "settings_delete_data", defaultValue: "Delete All Data"))
                        .fontWeight(.semibold)
                    Spacer()
                }
                .foregroundStyle(Color.crisisWarning)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.crisisWarning.opacity(0.10))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.crisisWarning.opacity(0.24), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .elevatedCard(stroke: Color.twistyOrange.opacity(0.22))
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel(
                title: String(localized: "settings_about_header", defaultValue: "About"),
                icon: "info.circle.fill",
                tint: .successGreen
            )

            NavigationLink {
                DisclaimerView()
            } label: {
                settingsLinkRow(
                    icon: "doc.text.fill",
                    title: String(localized: "settings_disclaimer", defaultValue: "Disclaimer"),
                    tint: .successGreen
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                CrisisView()
            } label: {
                settingsLinkRow(
                    icon: "cross.case.fill",
                    title: String(localized: "settings_emergency", defaultValue: "Emergency Contacts"),
                    tint: .crisisWarning
                )
            }
            .buttonStyle(.plain)

            HStack {
                Text(String(localized: "settings_version", defaultValue: "Version"))
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textPrimary)
            }
            .padding(.top, 2)
        }
        .padding(18)
        .elevatedCard(stroke: Color.successGreen.opacity(0.20))
    }

    private func sectionLabel(title: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
        }
    }

    private func settingsLinkRow(icon: String, title: String, tint: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.textPrimary)

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.appBackground.opacity(0.90))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(tint.opacity(0.16), lineWidth: 1)
        )
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
    .environment(SubscriptionManager.shared)
    .modelContainer(for: [MoodEntry.self, ThoughtRecord.self, BreathingSession.self], inMemory: true)
}
