import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("onboardingFlowVersion") private var onboardingFlowVersion = 0
    @AppStorage("launchThoughtWriterAfterOnboarding") private var launchThoughtWriterAfterOnboarding = false
    @AppStorage("onboardingDisplayName") private var onboardingDisplayName = ""
    private let requiredOnboardingFlowVersion = 2

    @State private var currentPage = 0
    @State private var isCompleting = false
    @State private var selectedNeeds: Set<OnboardingNeed> = [.overthinking]
    @State private var nameInput = ""
    @FocusState private var isNameFieldFocused: Bool

    private let totalPages = 5

    private var needsColumns: [GridItem] {
        [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    }

    var body: some View {
        ZStack {
            onboardingBackground

            VStack(spacing: 14) {
                if currentPage > 0 {
                    progressHeader
                }

                TabView(selection: $currentPage) {
                    stepWelcome.tag(0)
                    stepName.tag(1)
                    stepStory.tag(2)
                    stepNeeds.tag(3)
                    stepReady.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.28), value: currentPage)

                bottomBar
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 26)
        }
        .onAppear {
            if nameInput.isEmpty {
                nameInput = onboardingDisplayName
            }
        }
        .onChange(of: currentPage) { _, newPage in
            if newPage != 1 {
                isNameFieldFocused = false
            }
        }
    }

    private var onboardingBackground: some View {
        Group {
            switch currentPage {
            case 0:
                ZStack {
                    LinearGradient(
                        colors: [Color(red: 0.16, green: 0.14, blue: 0.35), Color(red: 0.10, green: 0.09, blue: 0.19)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Circle()
                        .fill(Color.primaryPurple.opacity(0.26))
                        .frame(width: 260, height: 260)
                        .blur(radius: 56)
                        .offset(x: 170, y: -260)

                    Circle()
                        .fill(Color.twistyOrange.opacity(0.20))
                        .frame(width: 210, height: 210)
                        .blur(radius: 56)
                        .offset(x: -160, y: 280)
                }
            case 4:
                ZStack {
                    LinearGradient(
                        colors: [Color.primaryPurple.opacity(0.96), Color.secondaryLavender.opacity(0.94)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Circle()
                        .fill(.white.opacity(0.08))
                        .frame(width: 220, height: 220)
                        .offset(x: 170, y: -250)

                    Circle()
                        .fill(.white.opacity(0.06))
                        .frame(width: 180, height: 180)
                        .offset(x: -170, y: 280)
                }
            default:
                ZStack {
                    Color.appBackground

                    Circle()
                        .fill(Color.primaryPurple.opacity(0.09))
                        .frame(width: 250, height: 250)
                        .blur(radius: 64)
                        .offset(x: 165, y: -250)

                    Circle()
                        .fill(Color.twistyOrange.opacity(0.07))
                        .frame(width: 220, height: 220)
                        .blur(radius: 58)
                        .offset(x: -170, y: 280)
                }
            }
        }
        .ignoresSafeArea()
        .onTapGesture {
            isNameFieldFocused = false
        }
    }

    private var progressHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "app_name", defaultValue: "Untwist"))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(currentPage == 4 ? .white : Color.textPrimary)

                Text(currentPageTitle)
                    .font(.caption)
                    .foregroundStyle(currentPage == 4 ? .white.opacity(0.72) : Color.textSecondary)
            }

            Spacer(minLength: 0)

            Text("\(currentPage + 1)/\(totalPages)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(currentPage == 4 ? Color.primaryPurple : Color.primaryPurple)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background((currentPage == 4 ? Color.white : Color.primaryPurple.opacity(0.16)), in: Capsule(style: .continuous))
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Capsule(style: .continuous)
                        .fill(index == currentPage ? activeDotColor : inactiveDotColor)
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
                            .tint(currentPage == 4 ? Color.primaryPurple : .white)
                    }
                }
                .foregroundStyle(currentPage == 4 ? Color.primaryPurple : .white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(currentPage == 4 ? Color.white : Color.primaryPurple)
                )
            }
            .disabled(!canContinue)
            .opacity(canContinue ? 1 : 0.62)
            .shadow(color: buttonShadowColor, radius: 10, y: 4)

            if currentPage == 2 {
                Button {
                    withAnimation {
                        currentPage = 3
                        isNameFieldFocused = false
                    }
                } label: {
                    Text(String(localized: "onboarding_skip", defaultValue: "Atla"))
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
            return !trimmedName.isEmpty
        }

        if currentPage == 3 {
            return !selectedNeeds.isEmpty
        }

        return true
    }

    private var activeDotColor: Color {
        currentPage == 4 ? .white : .primaryPurple
    }

    private var inactiveDotColor: Color {
        currentPage == 4 ? .white.opacity(0.34) : Color.primaryPurple.opacity(0.24)
    }

    private var buttonShadowColor: Color {
        currentPage == 4 ? Color.black.opacity(0.20) : Color.primaryPurple.opacity(0.22)
    }

    private var primaryButtonTitle: String {
        switch currentPage {
        case 0:
            return String(localized: "onboarding_cta_start", defaultValue: "Başlayalım")
        case 2:
            return String(localized: "onboarding_story_ack", defaultValue: "Tanıdık geldi")
        case 4:
            return String(localized: "onboarding_cta_finish", defaultValue: "Hadi başlayalım")
        default:
            return String(localized: "onboarding_cta_continue", defaultValue: "Devam et")
        }
    }

    private var currentPageTitle: String {
        switch currentPage {
        case 1:
            return String(localized: "onboarding_header_step_name", defaultValue: "Tanışma")
        case 2:
            return String(localized: "onboarding_header_step_story", defaultValue: "Hikaye")
        case 3:
            return String(localized: "onboarding_header_step_need", defaultValue: "İhtiyaç seçimi")
        case 4:
            return String(localized: "onboarding_header_step_ready", defaultValue: "Hazır")
        default:
            return ""
        }
    }

    private var displayName: String {
        trimmedName.isEmpty ? String(localized: "onboarding_default_name", defaultValue: "Dostum") : trimmedName
    }

    private var trimmedName: String {
        nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var stepWelcome: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 20)

            TwistyView(mood: .waving, size: 190)

            Text(String(localized: "app_name", defaultValue: "Untwist"))
                .font(.system(size: 36, weight: .black, design: .rounded))
                .italic()
                .foregroundStyle(.white)

            Text(String(localized: "onboarding_welcome_title", defaultValue: "Zihnini gevşet."))
                .font(.title2.weight(.bold))
                .foregroundStyle(.white.opacity(0.92))

            Text(String(localized: "onboarding_welcome_sub", defaultValue: "Her gün biraz daha iyi hissetmen için kısa ve etkili adımlar."))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.70))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 6)
    }

    private var stepName: some View {
        VStack(alignment: .leading, spacing: 14) {
            Spacer(minLength: 8)

            HStack(alignment: .top, spacing: 10) {
                TwistyView(mood: .waving, size: 72, animated: false)
                    .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "onboarding_name_prompt", defaultValue: "Önce bir şey sorayım..."))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.textPrimary)

                    Text(String(localized: "onboarding_name_prompt_sub", defaultValue: "Adın ne?"))
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.primaryPurple.opacity(0.16), lineWidth: 1)
                )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "onboarding_name_label", defaultValue: "Adın"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.8)

                TextField(String(localized: "onboarding_name_placeholder", defaultValue: "Adını yaz"), text: $nameInput)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .submitLabel(.done)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.appBackground.opacity(0.95))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.primaryPurple.opacity(0.18), lineWidth: 1.5)
                    )
                    .focused($isNameFieldFocused)
                    .onSubmit {
                        isNameFieldFocused = false
                    }

                Text(String(localized: "onboarding_name_hint", defaultValue: "Sana özel bir deneyim için."))
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(16)
            .elevatedCard(stroke: Color.primaryPurple.opacity(0.15), shadowColor: .black.opacity(0.06))

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isNameFieldFocused = true
            }
        }
    }

    private var stepStory: some View {
        VStack(alignment: .leading, spacing: 14) {
            Spacer(minLength: 6)

            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "onboarding_story_greeting", defaultValue: "Merhaba"))
                    .font(.caption.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(Color.primaryPurple)

                Text("\(displayName)! \(String(localized: "onboarding_story_title", defaultValue: "Seninle bir şey paylaşmak istiyorum."))")
                    .font(.title2.weight(.black))
                    .foregroundStyle(Color.textPrimary)
                    .lineSpacing(2)
            }

            TwistyView(mood: .thinking, size: 150, animated: false)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 10) {
                Text(String(localized: "onboarding_story_bubble_one", defaultValue: "Bazen zihnin durmaz. Bir düşünce takılır ve büyür. Bu senin hatan değil."))
                    .font(.subheadline)
                    .foregroundStyle(Color.textPrimary)
                    .lineSpacing(2)
                    .padding(14)
                    .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                Text(String(localized: "onboarding_story_bubble_two", defaultValue: "Untwist bu döngüyü birlikte çözmek için burada."))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.primaryPurple)
                    .lineSpacing(2)
                    .padding(14)
                    .background(Color.primaryPurple.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 2)
    }

    private var stepNeeds: some View {
        VStack(alignment: .leading, spacing: 14) {
            Spacer(minLength: 8)

            Text("\(displayName), \(String(localized: "onboarding_needs_title_personal", defaultValue: "seni en çok ne zorluyor?"))")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(3)
                .minimumScaleFactor(0.72)
                .fixedSize(horizontal: false, vertical: true)

            Text(String(localized: "onboarding_needs_sub", defaultValue: "Birden fazla seçim yapabilirsin. Sana uygun bir mini plan oluşturalım."))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 4)

            LazyVGrid(columns: needsColumns, spacing: 10) {
                ForEach(OnboardingNeed.allCases) { need in
                    Button {
                        toggleNeed(need)
                    } label: {
                        VStack(alignment: .leading, spacing: 7) {
                            Image(need.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)

                            Text(need.title)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color.textPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.84)

                            Text(need.subtitle)
                                .font(.caption)
                                .foregroundStyle(Color.textSecondary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.84)
                        }
                        .frame(maxWidth: .infinity, minHeight: 102, alignment: .topLeading)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(selectedNeeds.contains(need) ? Color.primaryPurple.opacity(0.10) : Color.cardBackground.opacity(0.86))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(selectedNeeds.contains(need) ? Color.primaryPurple : Color.primaryPurple.opacity(0.12), lineWidth: selectedNeeds.contains(need) ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var stepReady: some View {
        VStack {
            Spacer(minLength: 6)

            VStack(spacing: 16) {
                TwistyView(mood: .celebrating, size: 160, animated: false)

                Text("\(String(localized: "onboarding_ready_title", defaultValue: "Hazırsın,")) \(displayName)!")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(primaryNeedSummary)
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

                            Image(systemName: "checkmark")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 18, height: 18)
                                .background(.white.opacity(0.20), in: Circle())
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var selectedNeedsOrdered: [OnboardingNeed] {
        OnboardingNeed.allCases.filter(selectedNeeds.contains)
    }

    private var primaryNeedSummary: String {
        guard let need = selectedNeedsOrdered.first else {
            return String(localized: "onboarding_ready_default", defaultValue: "İlk adım için sana uygun bir başlangıç planı hazırladık.")
        }
        return String(
            localized: "onboarding_ready_selected_need",
            defaultValue: "\(need.readySummary) için doğru yerdesin."
        )
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
        return .thoughtUnwinder
    }

    private var personalizedActions: [OnboardingAction] {
        var actions: [OnboardingAction] = [primaryAction]

        if !actions.contains(.thoughtUnwinder) { actions.append(.thoughtUnwinder) }
        if !actions.contains(.moodCheck) { actions.append(.moodCheck) }
        if !actions.contains(.breathing) { actions.append(.breathing) }

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

        if currentPage < totalPages - 1 {
            withAnimation {
                currentPage += 1
                if currentPage != 1 {
                    isNameFieldFocused = false
                }
            }
            return
        }

        completeOnboarding(launchThoughtWriter: primaryAction == .thoughtUnwinder)
    }

    private func completeOnboarding(launchThoughtWriter: Bool) {
        guard !isCompleting else { return }

        isCompleting = true
        onboardingDisplayName = trimmedName
        launchThoughtWriterAfterOnboarding = launchThoughtWriter

        Task {
            _ = await NotificationManager.shared.requestPermission()
            await MainActor.run {
                hasCompletedOnboarding = true
                onboardingFlowVersion = requiredOnboardingFlowVersion
                isCompleting = false
                AnalyticsManager.shared.trackOnboardingCompleted()
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

    var subtitle: String {
        switch self {
        case .anxietyStress:
            return String(localized: "onboarding_need_anxiety_sub", defaultValue: "Sürekli gerginim")
        case .sadness:
            return String(localized: "onboarding_need_sadness_sub", defaultValue: "Motivasyonum düşük")
        case .overthinking:
            return String(localized: "onboarding_need_overthinking_sub", defaultValue: "Kafam durmuyor")
        case .sleep:
            return String(localized: "onboarding_need_sleep_sub", defaultValue: "Zihnim dinlenmiyor")
        case .relationship:
            return String(localized: "onboarding_need_relationship_sub", defaultValue: "Anlaşmakta zorlanıyorum")
        case .burnout:
            return String(localized: "onboarding_need_burnout_sub", defaultValue: "Yorgunluk geçmiyor")
        }
    }

    var readySummary: String {
        switch self {
        case .anxietyStress:
            return String(localized: "onboarding_ready_need_anxiety", defaultValue: "Kaygını sakinleştirmek")
        case .sadness:
            return String(localized: "onboarding_ready_need_sadness", defaultValue: "Duygularını düzenlemek")
        case .overthinking:
            return String(localized: "onboarding_ready_need_overthinking", defaultValue: "Aşırı düşünmeyi çözmek")
        case .sleep:
            return String(localized: "onboarding_ready_need_sleep", defaultValue: "Zihnini uykuya hazırlamak")
        case .relationship:
            return String(localized: "onboarding_ready_need_relationship", defaultValue: "İlişki düşüncelerini netleştirmek")
        case .burnout:
            return String(localized: "onboarding_ready_need_burnout", defaultValue: "Tükenmişliği azaltmak")
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
            return String(localized: "onboarding_action_mood", defaultValue: "Duygu Kaydı")
        case .thoughtTraps:
            return String(localized: "onboarding_action_traps", defaultValue: "Düşünce Tuzakları")
        }
    }
}

#Preview {
    OnboardingView()
}
