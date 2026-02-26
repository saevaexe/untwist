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
            Image("TwistyReading")
                .resizable()
                .scaledToFit()
                .padding(2)
                .frame(width: 42, height: 42)
                .background(Color.primaryPurple.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.primaryPurple.opacity(0.12), lineWidth: 1)
                )

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
            Untwist is a wellness self-help companion based on Cognitive Behavioral Therapy (CBT) principles.

            Untwist is not a medical or emergency service and cannot replace licensed professional support.

            Crisis resources are shown based on your selected or device region. Hotline availability and numbers may change over time. If no local hotline is available, Untwist directs you to findahelpline.com.

            If you are in immediate danger or may harm yourself or others, call your local emergency number now.

            Your entries stay on your device. Untwist does not collect or share your personal thought content.
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
