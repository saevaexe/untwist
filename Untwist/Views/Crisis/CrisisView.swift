import SwiftUI

struct CrisisView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAllCountries = false

    private let localHotlines = CrisisHotlineProvider.localHotlines
    private let otherHotlines = CrisisHotlineProvider.otherHotlines
    private let hasLocalHotlines = !CrisisHotlineProvider.localHotlines.isEmpty

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

                        // Local hotlines or findahelpline fallback
                        if hasLocalHotlines {
                            VStack(spacing: 10) {
                                ForEach(localHotlines) { hotline in
                                    hotlineButton(hotline: hotline, isLocal: true)
                                }
                            }
                            .padding(14)
                            .elevatedCard(stroke: Color.crisisWarning.opacity(0.26), shadowColor: Color.crisisWarning.opacity(0.12))
                        } else {
                            findAHelplineLink()
                                .padding(14)
                                .elevatedCard(stroke: Color.crisisWarning.opacity(0.26), shadowColor: Color.crisisWarning.opacity(0.12))
                        }

                        // Other countries expandable
                        VStack(spacing: 10) {
                            Button {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showAllCountries.toggle()
                                }
                            } label: {
                                HStack {
                                    Text(String(localized: "crisis_more_countries", defaultValue: "More countries"))
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(Color.textPrimary)

                                    Spacer()

                                    Image(systemName: showAllCountries ? "chevron.up" : "chevron.down")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color.textSecondary)
                                }
                                .padding(.vertical, 4)
                                .accessibilityLabel(showAllCountries
                                    ? String(localized: "crisis_collapse_countries", defaultValue: "Collapse country list")
                                    : String(localized: "crisis_expand_countries", defaultValue: "Expand country list"))
                            }
                            .buttonStyle(.plain)

                            if showAllCountries {
                                ForEach(otherHotlines) { hotline in
                                    hotlineButton(hotline: hotline, isLocal: false)
                                }

                                if hasLocalHotlines {
                                    findAHelplineLink()
                                }
                            }
                        }
                        .padding(14)
                        .elevatedCard(stroke: Color.crisisWarning.opacity(0.16), shadowColor: .black.opacity(0.06))

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

    // MARK: - Hotline Button

    private func hotlineButton(hotline: CrisisHotline, isLocal: Bool) -> some View {
        Button {
            if let url = hotline.phoneURL {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 12) {
                Text(CrisisHotlineProvider.flag(for: hotline.countryCode))
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(NSLocalizedString(hotline.nameKey, value: hotline.nameDefault, comment: ""))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.textPrimary)
                    Text(hotline.displayNumber)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                Image(systemName: "phone.fill")
                    .foregroundStyle(Color.crisisWarning)
            }
            .padding()
            .elevatedCard(cornerRadius: 16, stroke: isLocal ? Color.crisisWarning.opacity(0.28) : Color.crisisWarning.opacity(0.14), shadowColor: Color.crisisWarning.opacity(isLocal ? 0.10 : 0.05))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Find A Helpline

    private func findAHelplineLink() -> some View {
        Link(destination: CrisisHotlineProvider.findAHelplineURL) {
            HStack(spacing: 12) {
                Image(systemName: "globe")
                    .font(.title3)
                    .foregroundStyle(Color.primaryPurple)

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "crisis_findahelpline", defaultValue: "Find a Helpline"))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.textPrimary)
                    Text("findahelpline.com")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.primaryPurple)
            }
            .padding()
            .elevatedCard(cornerRadius: 16, stroke: Color.primaryPurple.opacity(0.20), shadowColor: .black.opacity(0.06))
        }
    }
}

#Preview {
    CrisisView()
}
