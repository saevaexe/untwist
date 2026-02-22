import SwiftUI

// MARK: - Mood State

enum TwistyMood {
    case happy, neutral, sad, calm
    case waving, thinking, celebrating, breathing, reading

    var imageName: String {
        switch self {
        case .happy: "TwistyHappy"
        case .neutral: "TwistyNeutral"
        case .sad: "TwistySad"
        case .calm: "TwistyCalm"
        case .waving: "TwistyWaving"
        case .thinking: "TwistyThinking"
        case .celebrating: "TwistyCelebrating"
        case .breathing: "TwistyBreathing"
        case .reading: "TwistyReading"
        }
    }
}

// MARK: - TwistyView

struct TwistyView: View {
    let mood: TwistyMood
    var size: CGFloat = 120
    var animated: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var bounce = false

    var body: some View {
        Image(mood.imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size)
            .offset(y: bounce ? -3 : 3)
            .onAppear {
                guard animated, !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    bounce = true
                }
            }
            .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        switch mood {
        case .happy: String(localized: "twisty_happy", defaultValue: "Twisty, happy yarn ball mascot")
        case .neutral: String(localized: "twisty_neutral", defaultValue: "Twisty, calm yarn ball mascot")
        case .sad: String(localized: "twisty_sad", defaultValue: "Twisty, sad yarn ball mascot")
        case .calm: String(localized: "twisty_calm", defaultValue: "Twisty, peaceful yarn ball mascot")
        case .waving: String(localized: "twisty_waving", defaultValue: "Twisty waving hello")
        case .thinking: String(localized: "twisty_thinking", defaultValue: "Twisty thinking")
        case .celebrating: String(localized: "twisty_celebrating", defaultValue: "Twisty celebrating")
        case .breathing: String(localized: "twisty_breathing", defaultValue: "Twisty breathing calmly")
        case .reading: String(localized: "twisty_reading", defaultValue: "Twisty reading a book")
        }
    }
}

// MARK: - Preview

#Preview("All Moods") {
    ScrollView {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(["happy", "neutral", "sad", "calm", "waving", "thinking", "celebrating", "breathing", "reading"], id: \.self) { name in
                let mood: TwistyMood = switch name {
                case "happy": .happy
                case "neutral": .neutral
                case "sad": .sad
                case "calm": .calm
                case "waving": .waving
                case "thinking": .thinking
                case "celebrating": .celebrating
                case "breathing": .breathing
                default: .reading
                }
                VStack {
                    TwistyView(mood: mood, size: 100)
                    Text(name.capitalized)
                        .font(.caption)
                }
            }
        }
        .padding()
    }
}
