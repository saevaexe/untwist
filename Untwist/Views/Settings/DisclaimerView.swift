import SwiftUI

struct DisclaimerView: View {
    var body: some View {
        ZStack {
            AppScreenBackground(
                primaryTint: Color.successGreen.opacity(0.14),
                secondaryTint: Color.primaryPurple.opacity(0.12),
                tertiaryTint: Color.twistyOrange.opacity(0.12)
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    headerCard
                    disclaimerCard
                    emergencyCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 120)
            }
        }
        .navigationTitle(String(localized: "disclaimer_title", defaultValue: "Disclaimer"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.successGreen)
                .frame(width: 42, height: 42)
                .background(Color.successGreen.opacity(0.14), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(String(localized: "disclaimer_title", defaultValue: "Disclaimer"))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(String(localized: "onboarding_privacy_note", defaultValue: "Your data stays on your device. We don't collect or share any personal information."))
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .elevatedCard(stroke: Color.successGreen.opacity(0.18), shadowColor: .black.opacity(0.07))
    }

    private var disclaimerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "disclaimer_body", defaultValue: """
            Untwist is a self-help wellness tool based on Cognitive Behavioral Therapy (CBT) principles.

            This app is NOT a substitute for professional therapy, counseling, or medical advice. It does not diagnose, treat, or cure any mental health condition.

            If you are experiencing a mental health crisis, please contact a licensed mental health professional or call your local emergency services immediately.

            Emergency contacts:
            • 988 Suicide & Crisis Lifeline (US)
            • 182 İntihar Önleme Hattı (TR)

            All data you enter stays on your device. We do not collect, store, or share any personal information.
            """))
                .font(.body)
                .foregroundStyle(Color.textPrimary)
                .lineSpacing(4)
        }
        .padding(18)
        .elevatedCard(stroke: Color.primaryPurple.opacity(0.16))
    }

    private var emergencyCard: some View {
        NavigationLink {
            CrisisView()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "cross.case.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.crisisWarning)
                    .frame(width: 36, height: 36)
                    .background(Color.crisisWarning.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                Text(String(localized: "settings_emergency", defaultValue: "Emergency Contacts"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(14)
            .elevatedCard(stroke: Color.crisisWarning.opacity(0.20))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        DisclaimerView()
    }
}
