import Foundation

enum ThoughtTrapType: String, Codable, CaseIterable, Identifiable {
    case allOrNothing
    case overgeneralization
    case mentalFilter
    case disqualifyingPositive
    case jumpingToConclusions
    case magnification
    case emotionalReasoning
    case shouldStatements
    case labeling
    case personalization

    var id: String { rawValue }

    var name: String {
        switch self {
        case .allOrNothing:
            String(localized: "trap_all_or_nothing", defaultValue: "All-or-Nothing Thinking")
        case .overgeneralization:
            String(localized: "trap_overgeneralization", defaultValue: "Overgeneralization")
        case .mentalFilter:
            String(localized: "trap_mental_filter", defaultValue: "Mental Filter")
        case .disqualifyingPositive:
            String(localized: "trap_disqualifying_positive", defaultValue: "Disqualifying the Positive")
        case .jumpingToConclusions:
            String(localized: "trap_jumping_conclusions", defaultValue: "Jumping to Conclusions")
        case .magnification:
            String(localized: "trap_magnification", defaultValue: "Magnification")
        case .emotionalReasoning:
            String(localized: "trap_emotional_reasoning", defaultValue: "Emotional Reasoning")
        case .shouldStatements:
            String(localized: "trap_should_statements", defaultValue: "Should Statements")
        case .labeling:
            String(localized: "trap_labeling", defaultValue: "Labeling")
        case .personalization:
            String(localized: "trap_personalization", defaultValue: "Personalization")
        }
    }

    var description: String {
        switch self {
        case .allOrNothing:
            String(localized: "trap_all_or_nothing_desc", defaultValue: "Seeing things in black and white — if it's not perfect, it's a total failure.")
        case .overgeneralization:
            String(localized: "trap_overgeneralization_desc", defaultValue: "Taking one negative event and expecting it to happen over and over again.")
        case .mentalFilter:
            String(localized: "trap_mental_filter_desc", defaultValue: "Focusing only on the negatives while ignoring the positives.")
        case .disqualifyingPositive:
            String(localized: "trap_disqualifying_positive_desc", defaultValue: "Dismissing positive experiences by insisting they don't count.")
        case .jumpingToConclusions:
            String(localized: "trap_jumping_conclusions_desc", defaultValue: "Making negative assumptions without actual evidence.")
        case .magnification:
            String(localized: "trap_magnification_desc", defaultValue: "Blowing things out of proportion or shrinking their importance.")
        case .emotionalReasoning:
            String(localized: "trap_emotional_reasoning_desc", defaultValue: "Believing something must be true because you feel it strongly.")
        case .shouldStatements:
            String(localized: "trap_should_statements_desc", defaultValue: "Putting pressure on yourself with rigid rules about how things should be.")
        case .labeling:
            String(localized: "trap_labeling_desc", defaultValue: "Attaching a negative label to yourself instead of describing the behavior.")
        case .personalization:
            String(localized: "trap_personalization_desc", defaultValue: "Blaming yourself for things outside your control.")
        }
    }

    var example: String {
        switch self {
        case .allOrNothing:
            String(localized: "trap_all_or_nothing_ex", defaultValue: "\"I got a B on the exam. I'm a complete failure.\"")
        case .overgeneralization:
            String(localized: "trap_overgeneralization_ex", defaultValue: "\"I didn't get the job. I'll never find work.\"")
        case .mentalFilter:
            String(localized: "trap_mental_filter_ex", defaultValue: "\"One person criticized my presentation. The whole thing was terrible.\"")
        case .disqualifyingPositive:
            String(localized: "trap_disqualifying_positive_ex", defaultValue: "\"They only said that to be nice. They didn't really mean it.\"")
        case .jumpingToConclusions:
            String(localized: "trap_jumping_conclusions_ex", defaultValue: "\"My friend didn't text back. They must be angry at me.\"")
        case .magnification:
            String(localized: "trap_magnification_ex", defaultValue: "\"I made a small mistake at work. I'll probably get fired.\"")
        case .emotionalReasoning:
            String(localized: "trap_emotional_reasoning_ex", defaultValue: "\"I feel anxious about flying, so it must be dangerous.\"")
        case .shouldStatements:
            String(localized: "trap_should_statements_ex", defaultValue: "\"I should always be productive. Resting means I'm lazy.\"")
        case .labeling:
            String(localized: "trap_labeling_ex", defaultValue: "\"I forgot to reply. I'm such a terrible person.\"")
        case .personalization:
            String(localized: "trap_personalization_ex", defaultValue: "\"My team lost the project. It's all my fault.\"")
        }
    }

    /// Keywords for rule-based trap detection (EN)
    var keywordsEN: [String] {
        switch self {
        case .allOrNothing:
            ["always", "never", "completely", "totally", "perfect", "ruined", "nothing", "everything", "worst", "impossible"]
        case .overgeneralization:
            ["always", "never", "everyone", "nobody", "every time", "nothing ever"]
        case .mentalFilter:
            ["only", "just the bad", "nothing good", "all negative", "can't see"]
        case .disqualifyingPositive:
            ["doesn't count", "they were just", "only because", "not really", "but that's"]
        case .jumpingToConclusions:
            ["they think", "they must", "i know they", "probably", "i bet", "going to be"]
        case .magnification:
            ["catastrophe", "disaster", "end of the world", "worst thing", "horrible", "can't handle"]
        case .emotionalReasoning:
            ["i feel like", "feels like", "must be true", "i feel so", "because i feel"]
        case .shouldStatements:
            ["should", "must", "have to", "ought to", "supposed to", "need to be"]
        case .labeling:
            ["i'm a", "i'm so", "i'm such a", "loser", "idiot", "stupid", "worthless", "failure"]
        case .personalization:
            ["my fault", "because of me", "i caused", "i'm to blame", "if only i"]
        }
    }

    /// Keywords for rule-based trap detection (TR)
    var keywordsTR: [String] {
        switch self {
        case .allOrNothing:
            ["hep", "hiç", "asla", "tamamen", "kesinlikle", "mükemmel", "berbat", "hiçbir şey", "her şey", "imkansız"]
        case .overgeneralization:
            ["hep", "hiçbir zaman", "herkes", "kimse", "her seferinde", "hiçbir şey"]
        case .mentalFilter:
            ["sadece", "kötü olan", "iyi bir şey yok", "hep olumsuz", "göremiyorum"]
        case .disqualifyingPositive:
            ["sayılmaz", "sadece şey", "sırf", "gerçekten değil", "ama o"]
        case .jumpingToConclusions:
            ["düşünüyordur", "kesin", "bence", "muhtemelen", "eminim", "olacak"]
        case .magnification:
            ["felaket", "yıkım", "dünyanın sonu", "en kötü", "korkunç", "kaldıramam"]
        case .emotionalReasoning:
            ["hissediyorum", "gibi hissediyorum", "doğru olmalı", "çok hissediyorum", "hissettiğim için"]
        case .shouldStatements:
            ["yapmalı", "etmeli", "zorunda", "gerekiyor", "lazım", "olmalı"]
        case .labeling:
            ["ben bir", "ben çok", "aptal", "salak", "değersiz", "işe yaramaz", "başarısız"]
        case .personalization:
            ["benim yüzümden", "benim hatam", "ben sebep oldum", "suçlu benim", "keşke ben"]
        }
    }
}
