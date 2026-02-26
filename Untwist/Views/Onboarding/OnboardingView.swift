import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("launchThoughtWriterAfterOnboarding") private var launchThoughtWriterAfterOnboarding = false
    @State private var currentPage = 0
    @State private var isCompleting = false
    @State private var selectedNeeds: Set<OnboardingNeed> = [.overthinking]
    @State private var selectedMood: OnboardingMood = .okay

    private var needsColumns: [GridItem] {
        [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    }

    var body: some View {
        ZStack {
            onboardingBackground

            VStack(spacing: 14) {
                progressHeader

                TabView(selection: $currentPage) {
                    stepWelcome.tag(0)
                    stepNeeds.tag(1)
                    stepMood.tag(2)
                    stepReady.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.28), value: currentPage)

                bottomBar
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 26)
        }
    }

    private var onboardingBackground: some View {
        ZStack {
            Color.appBackground

            Circle()
                .fill(Color.primaryPurple.opacity(0.08))
                .frame(width: 250, height: 250)
                .blur(radius: 64)
                .offset(x: 165, y: -250)

            Circle()
                .fill(Color.twistyOrange.opacity(0.06))
                .frame(width: 220, height: 220)
                .blur(radius: 58)
                .offset(x: -170, y: 280)
        }
        .ignoresSafeArea()
    }

    private var progressHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "app_name", defaultValue: "Untwist"))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)

                Text(currentPageTitle)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(currentPage + 1)/4")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.primaryPurple)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.primaryPurple.opacity(0.16), in: Capsule(style: .continuous))

                Text(estimatedTimeLabel)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { index in
                    Capsule(style: .continuous)
                        .fill(index == currentPage ? Color.primaryPurple : Color.primaryPurple.opacity(0.24))
                        .frame(width: index == currentPage ? 30 : 8, height: 8)
                        .animation(.spring(response: 0.26, dampingFraction: 0.86), value: currentPage)
                }
            }

            Button {
                handlePrimaryAction()
            } label: {
                HStack(spacing: 10) {
                    Text(primaryButtonTitle)
                        .font(.headline)

                    if isCompleting {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryPurple)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .disabled(!canContinue)
            .opacity(canContinue ? 1 : 0.62)
            .shadow(color: Color.primaryPurple.opacity(0.22), radius: 10, y: 4)

            if currentPage == 3 {
                Button {
                    completeOnboarding(launchThoughtWriter: false)
                } label: {
                    Text(String(localized: "onboarding_skip_for_now", defaultValue: "Skip for now"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textSecondary)
                }
                .disabled(isCompleting)
            }
        }
    }

    private var canContinue: Bool {
        guard !isCompleting else { return false }
        if currentPage == 1 {
            return !selectedNeeds.isEmpty
        }
        return true
    }

    private var primaryButtonTitle: String {
        switch currentPage {
        case 0:
            return String(localized: "onboarding_cta_start", defaultValue: "Başlayalım")
        case 1, 2:
            return String(localized: "onboarding_cta_continue", defaultValue: "Devam et")
        default:
            return String(localized: "onboarding_cta_finish", defaultValue: "Hadi başlayalım")
        }
    }

    private var currentPageTitle: String {
        switch currentPage {
        case 0:
            return String(localized: "onboarding_header_step_one", defaultValue: "Anlama")
        case 1:
            return String(localized: "onboarding_header_step_need", defaultValue: "İhtiyaç seçimi")
        case 2:
            return String(localized: "onboarding_header_step_mood", defaultValue: "Ruh hali")
        default:
            return String(localized: "onboarding_header_step_ready", defaultValue: "Hazır")
        }
    }

    private var estimatedTimeLabel: String {
        switch currentPage {
        case 0:
            return String(localized: "onboarding_eta_step_one", defaultValue: "~1 dk kaldı")
        case 1:
            return String(localized: "onboarding_eta_step_need", defaultValue: "~45 sn kaldı")
        case 2:
            return String(localized: "onboarding_eta_step_mood", defaultValue: "~30 sn kaldı")
        default:
            return String(localized: "onboarding_eta_step_ready", defaultValue: "~15 sn kaldı")
        }
    }

    private var stepWelcome: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 12)

            Text(String(localized: "app_name", defaultValue: "Untwist"))
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.primaryPurple)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.primaryPurple.opacity(0.12), in: Capsule(style: .continuous))

            twistyHero(mood: .waving, size: 146, tint: .primaryPurple)
                .padding(.top, 6)

            VStack(spacing: 0) {
                Text(String(localized: "onboarding_welcome_custom_title_top", defaultValue: "Zihnini"))
                    .font(.system(size: 54, weight: .black, design: .rounded))
                    .foregroundStyle(Color.textPrimary)

                Text(String(localized: "onboarding_welcome_custom_title_bottom", defaultValue: "gevşet."))
                    .font(.system(size: 52, weight: .bold, design: .serif))
                    .italic()
                    .foregroundStyle(Color.primaryPurple)
                    .offset(y: -8)
            }

            Text(
                String(
                    localized: "onboarding_welcome_custom_sub",
                    defaultValue: "Düşüncelerini, duygularını ve stresini birlikte çözelim."
                )
            )
            .font(.title3.weight(.medium))
            .foregroundStyle(Color.textSecondary)
            .multilineTextAlignment(.center)
            .lineSpacing(2)

            HStack(spacing: 10) {
                infoChip(String(localized: "onboarding_welcome_chip_speed", defaultValue: "2 dakikadan kisa"))
                infoChip(String(localized: "onboarding_welcome_chip_private", defaultValue: "Cihazinda gizli"))
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 4)
    }

    private var stepNeeds: some View {
        VStack(alignment: .leading, spacing: 14) {
            Spacer(minLength: 8)

            Text(String(localized: "onboarding_needs_badge", defaultValue: "SENİ TANIYALIM"))
                .font(.caption.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(Color.primaryPurple)

            Text(String(localized: "onboarding_needs_title", defaultValue: "Seni en çok ne zorluyor?"))
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.78)

            Text(
                String(
                    localized: "onboarding_needs_sub",
                    defaultValue: "Birden fazla seçim yapabilirsin. Sana uygun bir mini plan oluşturalım."
                )
            )
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.textSecondary)
            .padding(.bottom, 4)

            LazyVGrid(columns: needsColumns, spacing: 10) {
                ForEach(OnboardingNeed.allCases) { need in
                    Button {
                        toggleNeed(need)
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Image(need.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)

                            Text(need.title)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(Color.textPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.84)
                        }
                        .frame(maxWidth: .infinity, minHeight: 92, alignment: .topLeading)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(selectedNeeds.contains(need) ? Color.primaryPurple.opacity(0.10) : Color.cardBackground.opacity(0.78))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(selectedNeeds.contains(need) ? Color.primaryPurple : Color.primaryPurple.opacity(0.10), lineWidth: selectedNeeds.contains(need) ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 4)
    }

    private var stepMood: some View {
        VStack(alignment: .leading, spacing: 14) {
            Spacer(minLength: 8)

            Text(String(localized: "onboarding_mood_badge", defaultValue: "ŞU ANKİ HALİN"))
                .font(.caption.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(Color.primaryPurple)

            Text(String(localized: "onboarding_mood_title", defaultValue: "Bugün kendini nasıl hissediyorsun?"))
                .font(.system(size: 43, weight: .black, design: .rounded))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.80)

            Text(
                String(
                    localized: "onboarding_mood_sub",
                    defaultValue: "Ruh haline göre ilk adımı seçelim."
                )
            )
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.textSecondary)

            HStack(alignment: .top, spacing: 10) {
                ForEach(OnboardingMood.allCases) { mood in
                    Button {
                        selectedMood = mood
                    } label: {
                        VStack(spacing: 6) {
                            Image(mood.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 34, height: 34)
                                .padding(5)
                                .frame(width: 44, height: 44)
                                .background(mood.background, in: Circle())
                                .overlay(
                                    Circle()
                                        .stroke(selectedMood == mood ? Color.primaryPurple : Color.clear, lineWidth: 2)
                                )

                            Text(mood.label)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb")
                        .foregroundStyle(Color.twistyOrange)
                    Text(String(localized: "onboarding_recommendation_title", defaultValue: "Sana önerimiz"))
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                }

                Text(primaryAction.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)

                Text(primaryAction.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.primaryPurple.opacity(0.09))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.primaryPurple.opacity(0.14), lineWidth: 1)
            )
            .padding(.top, 4)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 4)
    }

    private var stepReady: some View {
        VStack {
            Spacer(minLength: 4)

            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.16))
                        .frame(width: 120, height: 120)

                    Image("TwistyCelebrating")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                }
                .padding(.top, 8)

                Text(String(localized: "onboarding_ready_title", defaultValue: "Hazırsın!"))
                    .font(.system(size: 46, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text(
                    String(
                        localized: "onboarding_ready_sub",
                        defaultValue: "Kişiselleştirilmiş deneyimin hazır. İşte senin için seçtiklerimiz:"
                    )
                )
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.84))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)

                VStack(spacing: 10) {
                    ForEach(personalizedActions) { action in
                        HStack(spacing: 10) {
                            Image(action.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)

                            Text(action.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)

                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(Color.primaryPurple.opacity(0.96))
            )

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func infoChip(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(0.74), in: Capsule(style: .continuous))
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color.primaryPurple.opacity(0.14), lineWidth: 1)
            )
    }

    private func twistyHero(mood: TwistyMood, size: CGFloat, tint: Color) -> some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.22))
                .frame(width: size + 62, height: size + 62)
                .blur(radius: 24)

            Circle()
                .fill(tint.opacity(0.10))
                .frame(width: size + 40, height: size + 40)

            TwistyView(mood: mood, size: size)
        }
    }

    private var primaryAction: OnboardingAction {
        if selectedNeeds.contains(.overthinking) || selectedNeeds.contains(.relationship) {
            return .thoughtUnwinder
        }
        if selectedNeeds.contains(.anxietyStress) || selectedNeeds.contains(.sleep) {
            return .breathing
        }
        if selectedNeeds.contains(.burnout) || selectedNeeds.contains(.sadness) {
            return .moodCheck
        }

        switch selectedMood {
        case .veryBad, .bad:
            return .breathing
        case .okay:
            return .thoughtUnwinder
        case .good, .great:
            return .moodCheck
        }
    }

    private var personalizedActions: [OnboardingAction] {
        var actions: [OnboardingAction] = [primaryAction]

        if !actions.contains(.breathing) { actions.append(.breathing) }
        if !actions.contains(.moodCheck) { actions.append(.moodCheck) }
        if selectedNeeds.contains(.overthinking) && !actions.contains(.thoughtTraps) {
            actions.append(.thoughtTraps)
        }

        return Array(actions.prefix(3))
    }

    private func toggleNeed(_ need: OnboardingNeed) {
        if selectedNeeds.contains(need) {
            selectedNeeds.remove(need)
        } else {
            selectedNeeds.insert(need)
        }
    }

    private func handlePrimaryAction() {
        guard canContinue else { return }

        if currentPage < 3 {
            withAnimation { currentPage += 1 }
            return
        }

        completeOnboarding(launchThoughtWriter: primaryAction == .thoughtUnwinder)
    }

    private func completeOnboarding(launchThoughtWriter: Bool) {
        guard !isCompleting else { return }

        isCompleting = true
        launchThoughtWriterAfterOnboarding = launchThoughtWriter

        Task {
            _ = await NotificationManager.shared.requestPermission()
            await MainActor.run {
                hasCompletedOnboarding = true
                isCompleting = false
            }
        }
    }
}

private enum OnboardingNeed: String, CaseIterable, Identifiable {
    case anxietyStress
    case sadness
    case overthinking
    case sleep
    case relationship
    case burnout

    var id: String { rawValue }

    var imageName: String {
        switch self {
        case .anxietyStress: return "TwistyBreathing"
        case .sadness: return "TwistySad"
        case .overthinking: return "TwistyThinking"
        case .sleep: return "TwistyCalm"
        case .relationship: return "TwistyWaving"
        case .burnout: return "TwistyNeutral"
        }
    }

    var title: String {
        switch self {
        case .anxietyStress:
            return String(localized: "onboarding_need_anxiety", defaultValue: "Kaygı ve stres")
        case .sadness:
            return String(localized: "onboarding_need_sadness", defaultValue: "Üzgün hissetmek")
        case .overthinking:
            return String(localized: "onboarding_need_overthinking", defaultValue: "Aşırı düşünme")
        case .sleep:
            return String(localized: "onboarding_need_sleep", defaultValue: "Uyku sorunları")
        case .relationship:
            return String(localized: "onboarding_need_relationship", defaultValue: "İlişki sorunları")
        case .burnout:
            return String(localized: "onboarding_need_burnout", defaultValue: "Tükenmişlik")
        }
    }
}

private enum OnboardingMood: Int, CaseIterable, Identifiable {
    case veryBad
    case bad
    case okay
    case good
    case great

    var id: Int { rawValue }

    var imageName: String {
        switch self {
        case .veryBad: return "TwistySad"
        case .bad: return "TwistyNeutral"
        case .okay: return "TwistyThinking"
        case .good: return "TwistyHappy"
        case .great: return "TwistyCelebrating"
        }
    }

    var label: String {
        switch self {
        case .veryBad:
            return String(localized: "onboarding_mood_very_bad", defaultValue: "Çok kötü")
        case .bad:
            return String(localized: "onboarding_mood_bad", defaultValue: "Kötü")
        case .okay:
            return String(localized: "onboarding_mood_okay", defaultValue: "Orta")
        case .good:
            return String(localized: "onboarding_mood_good", defaultValue: "İyi")
        case .great:
            return String(localized: "onboarding_mood_great", defaultValue: "Harika")
        }
    }

    var background: Color {
        switch self {
        case .veryBad: return Color.twistyOrange.opacity(0.18)
        case .bad: return Color.twistyOrange.opacity(0.24)
        case .okay: return Color.primaryPurple.opacity(0.18)
        case .good: return Color.successGreen.opacity(0.18)
        case .great: return Color.successGreen.opacity(0.24)
        }
    }
}

private enum OnboardingAction: String, CaseIterable, Identifiable {
    case thoughtUnwinder
    case breathing
    case moodCheck
    case thoughtTraps

    var id: String { rawValue }

    var imageName: String {
        switch self {
        case .thoughtUnwinder: return "TwistyThinking"
        case .breathing: return "TwistyBreathing"
        case .moodCheck: return "TwistyHappy"
        case .thoughtTraps: return "TrapCatastrophizing"
        }
    }

    var title: String {
        switch self {
        case .thoughtUnwinder:
            return String(localized: "onboarding_action_unwinder", defaultValue: "Düşünce Çözücü")
        case .breathing:
            return String(localized: "onboarding_action_breathing", defaultValue: "Nefes Egzersizi")
        case .moodCheck:
            return String(localized: "onboarding_action_mood", defaultValue: "Günlük Duygu Kaydı")
        case .thoughtTraps:
            return String(localized: "onboarding_action_traps", defaultValue: "Düşünce Tuzakları")
        }
    }

    var subtitle: String {
        switch self {
        case .thoughtUnwinder:
            return String(localized: "onboarding_action_unwinder_sub", defaultValue: "Bir düşünceyi keşfet ve yeniden çerçevele")
        case .breathing:
            return String(localized: "onboarding_action_breathing_sub", defaultValue: "2 dakikadan kısa hızlı bir sakinleşme")
        case .moodCheck:
            return String(localized: "onboarding_action_mood_sub", defaultValue: "Duygularını takip et ve kalıpları gör")
        case .thoughtTraps:
            return String(localized: "onboarding_action_traps_sub", defaultValue: "Yaygın düşünce kalıplarını tanı")
        }
    }
}

#Preview {
    OnboardingView()
}
