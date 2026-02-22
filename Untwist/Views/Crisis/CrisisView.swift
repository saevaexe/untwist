import SwiftUI

struct CrisisView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Calm Twisty
                    VStack(spacing: 12) {
                        TwistyView(mood: .calm, size: 140)

                        Text(String(localized: "crisis_title", defaultValue: "You're not alone"))
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(Color.textPrimary)

                        Text(String(localized: "crisis_subtitle", defaultValue: "If you're in crisis, please reach out. Help is available right now."))
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 32)

                    // Hotlines
                    VStack(spacing: 12) {
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
                    .padding(.horizontal)

                    // Breathing shortcut
                    NavigationLink {
                        BreathingView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "wind")
                                .font(.title3)
                                .foregroundStyle(Color.successGreen)

                            Text(String(localized: "crisis_breathing", defaultValue: "Try a breathing exercise"))
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.textPrimary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(Color.textSecondary)
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)

                    // Continue writing
                    Button {
                        dismiss()
                    } label: {
                        Text(String(localized: "crisis_continue", defaultValue: "Continue what I was doing"))
                            .font(.subheadline)
                            .foregroundStyle(Color.primaryPurple)
                    }
                    .padding(.top, 8)
                }
            }
            .background(Color.appBackground)
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
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.crisisWarning.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
    CrisisView()
}
