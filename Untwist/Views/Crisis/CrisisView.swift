import SwiftUI

struct CrisisView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("crisisCountryOverride") private var crisisCountryOverride = ""
    @State private var showAllCountries = false

    private var resolvedCountryCode: String? {
        CrisisHotlineProvider.resolvedCountryCode(overrideCode: crisisCountryOverride)
    }

    private var localHotlines: [CrisisHotline] {
        CrisisHotlineProvider.localHotlines(for: resolvedCountryCode)
    }

    private var otherHotlines: [CrisisHotline] {
        CrisisHotlineProvider.otherHotlines(for: resolvedCountryCode)
    }

    private var hasLocalHotlines: Bool {
        !localHotlines.isEmpty
    }

    private var usingManualOverride: Bool {
        !crisisCountryOverride.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var countryMenuOptions: [String] {
        CrisisHotlineProvider.supportedCountryCodes.sorted {
            CrisisHotlineProvider.countryName(for: $0) < CrisisHotlineProvider.countryName(for: $1)
        }
    }

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
                            TwistyView(mood: .calm, size: 160)

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

                        regionSelectorCard

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
            .onAppear {
                AnalyticsManager.trackMilestone(.crisisScreenOpened)
            }
        }
    }

    // MARK: - Hotline Button

    private var regionSelectorCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "globe.europe.africa.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.primaryPurple)

                Text(String(localized: "crisis_region_title", defaultValue: "Region"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
            }

            Menu {
                Button {
                    crisisCountryOverride = ""
                } label: {
                    if !usingManualOverride {
                        Label(String(localized: "crisis_region_auto", defaultValue: "Use device region (automatic)"), systemImage: "checkmark")
                    } else {
                        Text(String(localized: "crisis_region_auto", defaultValue: "Use device region (automatic)"))
                    }
                }

                ForEach(countryMenuOptions, id: \.self) { countryCode in
                    Button {
                        crisisCountryOverride = countryCode
                    } label: {
                        if countryCode == resolvedCountryCode && usingManualOverride {
                            Label(countryLabel(for: countryCode), systemImage: "checkmark")
                        } else {
                            Text(countryLabel(for: countryCode))
                        }
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Text(currentRegionLabel)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.appBackground.opacity(0.9))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.primaryPurple.opacity(0.18), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            Text(String(localized: "crisis_region_note", defaultValue: "If your region looks wrong, pick another country."))
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(14)
        .elevatedCard(stroke: Color.primaryPurple.opacity(0.16), shadowColor: .black.opacity(0.06))
    }

    private var currentRegionLabel: String {
        if let code = resolvedCountryCode {
            return countryLabel(for: code)
        }
        return String(localized: "crisis_region_unknown", defaultValue: "Unknown region")
    }

    private func countryLabel(for countryCode: String) -> String {
        "\(CrisisHotlineProvider.flag(for: countryCode)) \(CrisisHotlineProvider.countryName(for: countryCode))"
    }

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
