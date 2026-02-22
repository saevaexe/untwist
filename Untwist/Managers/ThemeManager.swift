import SwiftUI

extension Color {
    // Primary
    static let primaryPurple = Color(light: .init(hex: 0x7C6BC4), dark: .init(hex: 0x9B8FD8))
    static let secondaryLavender = Color(hex: 0xA89BD4)

    // Background
    static let appBackground = Color(light: .init(hex: 0xFAF8FF), dark: .init(hex: 0x1A1528))
    static let cardBackground = Color(light: .white, dark: .init(hex: 0x251E36))

    // Text
    static let textPrimary = Color(light: .init(hex: 0x2D2344), dark: .init(hex: 0xF0ECF8))
    static let textSecondary = Color(hex: 0x6B6189)

    // Semantic
    static let successGreen = Color(hex: 0x5BBD8A)
    static let crisisWarning = Color(hex: 0xE8736C)

    // Twisty
    static let twistyOrange = Color(hex: 0xF2A65A)
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
