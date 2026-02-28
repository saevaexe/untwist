import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var offering: Offering?
    @State private var isLoadingOffering = true
    @State private var selectedPlan: PlanType = .yearly
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    private enum PlanType {
        case monthly, yearly
    }

    private var monthlyPackage: Package? {
        offering?.availablePackages.first {
            $0.storeProduct.productIdentifier == AppConstants.Subscription.monthlyProductID
        }
    }

    private var yearlyPackage: Package? {
        offering?.availablePackages.first {
            $0.storeProduct.productIdentifier == AppConstants.Subscription.yearlyProductID
        }
    }

    private var selectedPackage: Package? {
        selectedPlan == .monthly ? monthlyPackage : yearlyPackage
    }

    var body: some View {
        NavigationStack {
            Group {
                if offering != nil {
                    paywallContent
                } else if isLoadingOffering {
                    VStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    unavailableView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                    }
                }
            }
            .alert(String(localized: "paywall_error", defaultValue: "Error"), isPresented: .init(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: {
                if let msg = errorMessage { Text(msg) }
            }
        }
        .task {
            AnalyticsManager.shared.trackPaywallShown()
            await loadOffering()
        }
    }

    // MARK: - Paywall Content

    private var paywallContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                headerSection
                featuresSection
                productsSection
                purchaseButton
                restoreButton
                legalLinks
                subscriptionDisclosure
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(
            LinearGradient(
                colors: [Color.appBackground, Color.primaryPurple.opacity(0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            TwistyView(mood: .waving, size: 160)

            Text(String(localized: "paywall_title", defaultValue: "Unlock Untwist Pro"))
                .font(.title2.bold())
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)

            Text(String(localized: "paywall_subtitle", defaultValue: "Your full CBT toolkit, always with you"))
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 12)
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            featureRow(
                icon: "sparkles",
                text: String(localized: "paywall_feature_ai", defaultValue: "AI-powered reframe suggestions"),
                subtitle: String(localized: "paywall_feature_ai_sub", defaultValue: "Personalized alternatives for your thoughts"),
                tint: .primaryPurple
            )
            featureRow(
                icon: "infinity",
                text: String(localized: "paywall_feature_unlimited", defaultValue: "Unlimited thought records"),
                subtitle: String(localized: "paywall_feature_unlimited_sub", defaultValue: "No daily limits on journaling"),
                tint: .successGreen
            )
            featureRow(
                icon: "star.fill",
                text: String(localized: "paywall_feature_priority", defaultValue: "Priority access to new features"),
                subtitle: String(localized: "paywall_feature_priority_sub", defaultValue: "Be the first to try what's next"),
                tint: .twistyOrange
            )
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.cardBackground.opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.primaryPurple.opacity(0.16), lineWidth: 1)
        )
    }

    private func featureRow(icon: String, text: String, subtitle: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textPrimary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }

    // MARK: - Products

    private var productsSection: some View {
        HStack(spacing: 12) {
            if let pkg = monthlyPackage {
                productCard(
                    type: .monthly,
                    price: pkg.storeProduct.localizedPriceString,
                    period: String(localized: "paywall_per_month", defaultValue: "/month")
                )
            }
            if let pkg = yearlyPackage {
                productCard(
                    type: .yearly,
                    price: pkg.storeProduct.localizedPriceString,
                    period: String(localized: "paywall_per_year", defaultValue: "/year")
                )
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func productCard(type: PlanType, price: String, period: String) -> some View {
        let isSelected = selectedPlan == type
        let isYearly = type == .yearly

        return Button {
            selectedPlan = type
        } label: {
            VStack(spacing: 8) {
                Text(isYearly
                     ? String(localized: "paywall_plan_yearly", defaultValue: "Yearly")
                     : String(localized: "paywall_plan_monthly", defaultValue: "Monthly"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isSelected ? Color.primaryPurple : Color.textSecondary)

                Text(price)
                    .font(.title2.bold())
                    .foregroundStyle(Color.textPrimary)

                Text(period)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)

                if isYearly, let perDay = perDayPrice {
                    Text(perDay)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color.successGreen)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 110)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.primaryPurple.opacity(0.10) : Color.cardBackground.opacity(0.96))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.primaryPurple : Color.primaryPurple.opacity(0.12), lineWidth: isSelected ? 2 : 1)
            )
            .overlay(alignment: .top) {
                if isYearly, let savings = savingsPercent {
                    Text(String(
                        format: String(localized: "paywall_savings %lld", defaultValue: "Save %lld%%"),
                        Int64(savings)
                    ))
                    .font(.caption2.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.successGreen.gradient, in: Capsule())
                    .offset(y: -10)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Purchase Button

    private var purchaseButton: some View {
        VStack(spacing: 8) {
            Button {
                Task { await purchase() }
            } label: {
                VStack(spacing: 4) {
                    Group {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(String(localized: "paywall_cta", defaultValue: "Start Free Trial"))
                        }
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)

                    if !isPurchasing {
                        Text(String(localized: "paywall_trial_detail", defaultValue: "3-day free trial, then auto-renews"))
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.88))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(
                    LinearGradient(
                        colors: [Color.primaryPurple, Color.primaryPurple.opacity(0.85)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.primaryPurple.opacity(0.30), radius: 10, y: 4)
            }
            .disabled(isPurchasing || selectedPackage == nil)
            .opacity(selectedPackage == nil ? 0.6 : 1.0)

            Text(String(localized: "paywall_no_charge", defaultValue: "No charge today · Cancel anytime"))
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
    }

    // MARK: - Restore

    private var restoreButton: some View {
        Button {
            Task { await restorePurchases() }
        } label: {
            Text(String(localized: "paywall_restore", defaultValue: "Restore Purchases"))
                .font(.footnote)
                .foregroundStyle(Color.textSecondary)
        }
    }

    // MARK: - Legal Links

    private var legalLinks: some View {
        HStack(spacing: 16) {
            Link(String(localized: "paywall_terms", defaultValue: "Terms of Use"),
                 destination: URL(string: "https://saevaexe.github.io/untwist/terms.html")!)
            Text("·").foregroundStyle(Color.textSecondary)
            Link(String(localized: "paywall_privacy", defaultValue: "Privacy Policy"),
                 destination: URL(string: "https://saevaexe.github.io/untwist/privacy.html")!)
        }
        .font(.caption)
        .foregroundStyle(Color.textSecondary)
    }

    // MARK: - Subscription Disclosure

    private var subscriptionDisclosure: some View {
        Text(String(localized: "paywall_disclosure", defaultValue: "Payment will be charged to your Apple ID account at the confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your App Store account settings after purchase."))
            .font(.caption2)
            .foregroundStyle(Color.textSecondary.opacity(0.75))
            .multilineTextAlignment(.center)
            .lineSpacing(1)
            .padding(.horizontal)
    }

    // MARK: - Computed

    private var savingsPercent: Int? {
        guard
            let monthly = monthlyPackage,
            let yearly = yearlyPackage
        else { return nil }

        let monthlyPrice = monthly.storeProduct.price as Decimal
        let yearlyPrice = yearly.storeProduct.price as Decimal
        guard monthlyPrice > 0 else { return nil }

        let annualMonthlyCost = monthlyPrice * 12
        let savings = ((annualMonthlyCost - yearlyPrice) / annualMonthlyCost) * 100
        let roundedSavings = Int(NSDecimalNumber(decimal: savings).doubleValue.rounded())
        return roundedSavings > 0 ? roundedSavings : nil
    }

    private var perDayPrice: String? {
        guard let yearly = yearlyPackage else { return nil }
        let yearlyPrice = NSDecimalNumber(decimal: yearly.storeProduct.price as Decimal).doubleValue
        guard yearlyPrice > 0 else { return nil }
        let daily = yearlyPrice / 365.0

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = yearly.storeProduct.priceFormatter?.locale ?? .current
        formatter.maximumFractionDigits = 2

        guard let formatted = formatter.string(from: NSNumber(value: daily)) else { return nil }
        return String(
            format: String(localized: "paywall_per_day %@", defaultValue: "%@/day"),
            formatted
        )
    }

    // MARK: - Actions

    @MainActor
    private func purchase() async {
        guard let package = selectedPackage else { return }
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let (_, _, _) = try await Purchases.shared.purchase(package: package)
            await subscriptionManager.checkSubscriptionStatus()
            if subscriptionManager.hasFullAccess {
                dismiss()
            }
        } catch {
            if !((error as NSError).domain == "RevenueCat.ErrorCode" && (error as NSError).code == 1) {
                errorMessage = error.localizedDescription
            }
        }
    }

    @MainActor
    private func restorePurchases() async {
        do {
            _ = try await Purchases.shared.restorePurchases()
            await subscriptionManager.checkSubscriptionStatus()
            if subscriptionManager.hasFullAccess {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func loadOffering() async {
        isLoadingOffering = true
        defer { isLoadingOffering = false }

        do {
            let offerings = try await Purchases.shared.offerings()
            if let current = offerings.current, !current.availablePackages.isEmpty {
                offering = current
            } else {
                offering = nil
            }
        } catch {
            offering = nil
            print("Failed to load offerings: \(error)")
        }
    }

    // MARK: - Unavailable View

    private var unavailableView: some View {
        VStack(spacing: 20) {
            Spacer()

            TwistyView(mood: .thinking, size: 80)

            Text(String(localized: "paywall_unavailable", defaultValue: "Subscription is currently unavailable. Please try again later."))
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                Task {
                    await subscriptionManager.restorePurchases()
                    await subscriptionManager.checkSubscriptionStatus()
                    if subscriptionManager.hasFullAccess {
                        dismiss()
                    }
                }
            } label: {
                Text(String(localized: "paywall_restore", defaultValue: "Restore Purchases"))
                    .font(.subheadline.bold())
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.primaryPurple.opacity(0.1), in: Capsule())
            }
            .buttonStyle(.plain)

            Button {
                dismiss()
            } label: {
                Text(String(localized: "paywall_maybe_later", defaultValue: "Maybe Later"))
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
