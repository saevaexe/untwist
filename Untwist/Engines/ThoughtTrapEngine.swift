import Foundation

struct TrapSuggestion: Identifiable {
    let id = UUID()
    let trap: ThoughtTrapType
    let score: Double // 0.0 - 1.0
}

struct ThoughtTrapEngine {

    /// Analyze text and suggest possible thought traps
    /// - Parameters:
    ///   - text: The automatic thought text to analyze
    ///   - locale: Current locale for keyword matching
    /// - Returns: Sorted suggestions (highest score first), filtered by threshold ≥ 0.3
    static func analyze(_ text: String, locale: Locale = .current) -> [TrapSuggestion] {
        let lowercased = text.lowercased()
        let isTurkish = locale.language.languageCode?.identifier == "tr"

        return ThoughtTrapType.allCases
            .map { trap in
                let keywords = isTurkish ? trap.keywordsTR : trap.keywordsEN
                let matchCount = keywords.filter { lowercased.contains($0) }.count

                let score: Double = switch matchCount {
                case 0: 0.0
                case 1: 0.3
                case 2: 0.6
                default: 0.9
                }

                return TrapSuggestion(trap: trap, score: score)
            }
            .filter { $0.score >= 0.3 }
            .sorted { $0.score > $1.score }
    }

    // MARK: - Crisis Detection

    private static let crisisKeywordsEN = [
        "kill myself", "want to die", "end my life", "suicide",
        "don't want to live", "no reason to live", "better off dead",
        "can't go on", "end it all"
    ]

    private static let crisisKeywordsTR = [
        "kendimi öldür", "ölmek istiyorum", "yaşamak istemiyorum",
        "intihar", "hayatıma son", "yaşamanın anlamı yok",
        "ölsem daha iyi", "dayanamıyorum", "her şeyi bitir"
    ]

    /// Detect crisis language in text — HIGH threshold, only clear crisis language
    static func detectCrisis(_ text: String, locale: Locale = .current) -> Bool {
        let lowercased = text.lowercased()
        let isTurkish = locale.language.languageCode?.identifier == "tr"
        let keywords = isTurkish ? crisisKeywordsTR : crisisKeywordsEN
        return keywords.contains { lowercased.contains($0) }
    }
}
