import SwiftUI

extension Color {
    // Primary
    static let primaryPurple = Color(light: .init(hex: 0x6B5FD4), dark: .init(hex: 0x9B8FD8))
    static let secondaryLavender = Color(hex: 0xA89BD4)

    // Background
    static let appBackground = Color(light: .init(hex: 0xF0EFF8), dark: .init(hex: 0x1A1528))
    static let cardBackground = Color(light: .white, dark: .init(hex: 0x251E36))

    // Text
    static let textPrimary = Color(light: .init(hex: 0x2D2344), dark: .init(hex: 0xF0ECF8))
    static let textSecondary = Color(light: .init(hex: 0x6B6189), dark: .init(hex: 0xC2BADB))

    // Semantic
    static let successGreen = Color(hex: 0x52C4A0)
    static let crisisWarning = Color(hex: 0xE8736C)

    // Twisty
    static let twistyOrange = Color(hex: 0xF4A46A)
}

// MARK: - Hex Initializer

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }

    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

struct AppScreenBackground: View {
    var primaryTint: Color = Color.primaryPurple.opacity(0.18)
    var secondaryTint: Color = Color.twistyOrange.opacity(0.20)
    var tertiaryTint: Color = Color.successGreen.opacity(0.14)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appBackground, Color.primaryPurple.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(primaryTint)
                .frame(width: 260, height: 260)
                .blur(radius: 60)
                .offset(x: -160, y: -260)

            Circle()
                .fill(secondaryTint)
                .frame(width: 300, height: 300)
                .blur(radius: 70)
                .offset(x: 170, y: -120)

            Circle()
                .fill(tertiaryTint)
                .frame(width: 220, height: 220)
                .blur(radius: 55)
                .offset(x: -130, y: 280)
        }
        .ignoresSafeArea()
    }
}

struct ElevatedCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 24
    var stroke: Color = Color.primaryPurple.opacity(0.14)
    var shadowColor: Color = .black.opacity(0.10)

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.cardBackground.opacity(0.95))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(stroke, lineWidth: 1)
            )
            .shadow(color: shadowColor, radius: 14, y: 6)
    }
}

extension View {
    func elevatedCard(
        cornerRadius: CGFloat = 24,
        stroke: Color = Color.primaryPurple.opacity(0.14),
        shadowColor: Color = .black.opacity(0.10)
    ) -> some View {
        modifier(
            ElevatedCardModifier(
                cornerRadius: cornerRadius,
                stroke: stroke,
                shadowColor: shadowColor
            )
        )
    }
}
