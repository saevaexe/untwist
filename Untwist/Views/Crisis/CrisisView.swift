import SwiftUI

struct CrisisView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppScreenBackground(
                    primaryTint: Color.crisisWarning.opacity(0.17),
                    secondaryTint: Color.primaryPurple.opacity(0.10),
                    tertiaryTint: Color.successGreen.opacity(0.08)
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Calm Twisty
                        VStack(spacing: 10) {
                            TwistyView(mood: .calm, size: 132)

                            Text(String(localized: "crisis_title", defaultValue: "You're not alone"))
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(Color.textPrimary)

                            Text(String(localized: "crisis_subtitle", defaultValue: "If you're in crisis, please reach out. Help is available right now."))
                                .font(.subheadline)
                                .foregroundStyle(Color.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                        }
                        .padding(18)
                        .elevatedCard(stroke: Color.crisisWarning.opacity(0.24), shadowColor: Color.crisisWarning.opacity(0.12))

                        // Hotlines
                        VStack(spacing: 10) {
                            hotlineButton(
                                country: "🇺🇸",
                                label: String(localized: "crisis_988", defaultValue: "988 Suicide & Crisis Lifeline"),
                                number: "988"
                            )

                            hotlineButton(
                                country: "🇹🇷",
                                label: String(localized: "crisis_182", defaultValue: "182 İntihar Önleme Hattı"),
                                number: "182"
                            )
                        }
                        .padding(14)
                        .elevatedCard(stroke: Color.crisisWarning.opacity(0.26), shadowColor: Color.crisisWarning.opacity(0.12))

                        // Breathing shortcut
                        NavigationLink {
                            BreathingView()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "wind")
                                    .font(.title3)
                                    .foregroundStyle(Color.successGreen)

                                Text(String(localized: "crisis_breathing", defaultValue: "Try a breathing exercise"))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.textPrimary)

                                Spacer()

                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(Color.primaryPurple)
                            }
                            .padding(16)
                            .elevatedCard(stroke: Color.successGreen.opacity(0.25), shadowColor: .black.opacity(0.08))
                        }
                        .buttonStyle(.plain)

                        // Continue writing
                        Button {
                            dismiss()
                        } label: {
                            Text(String(localized: "crisis_continue", defaultValue: "Continue what I was doing"))
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.primaryPurple)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }
        }
    }

    private func hotlineButton(country: String, label: String, number: String) -> some View {
        Button {
            if let url = URL(string: "tel://\(number)") {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 12) {
                Text(country)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.textPrimary)
                    Text(number)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                Image(systemName: "phone.fill")
                    .foregroundStyle(Color.crisisWarning)
            }
            .padding()
            .elevatedCard(cornerRadius: 16, stroke: Color.crisisWarning.opacity(0.28), shadowColor: Color.crisisWarning.opacity(0.10))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CrisisView()
}
