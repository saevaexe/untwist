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

    var imageName: String {
        switch self {
        case .allOrNothing: "TrapAllOrNothing"
        case .overgeneralization: "TrapOvergeneralization"
        case .mentalFilter: "TrapMentalFilter"
        case .disqualifyingPositive: "TrapDisqualifyPositive"
        case .jumpingToConclusions: "TrapMindReading"
        case .magnification: "TrapCatastrophizing"
        case .emotionalReasoning: "TrapEmotionalReasoning"
        case .shouldStatements: "TrapShouldStatements"
        case .labeling: "TrapLabeling"
        case .personalization: "TrapFortuneTelling"
        }
    }

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

    var examples: [String] {
        switch self {
        case .allOrNothing: [
            String(localized: "trap_all_or_nothing_ex", defaultValue: "\"I got a B on the exam. I'm a complete failure.\""),
            String(localized: "trap_all_or_nothing_ex2", defaultValue: "\"If I can't do it perfectly, there's no point in trying.\""),
            String(localized: "trap_all_or_nothing_ex3", defaultValue: "\"My diet is ruined because I ate one cookie.\"")
        ]
        case .overgeneralization: [
            String(localized: "trap_overgeneralization_ex", defaultValue: "\"I didn't get the job. I'll never find work.\""),
            String(localized: "trap_overgeneralization_ex2", defaultValue: "\"This relationship failed. I'm destined to be alone.\""),
            String(localized: "trap_overgeneralization_ex3", defaultValue: "\"I failed the test again. I always mess things up.\"")
        ]
        case .mentalFilter: [
            String(localized: "trap_mental_filter_ex", defaultValue: "\"One person criticized my presentation. The whole thing was terrible.\""),
            String(localized: "trap_mental_filter_ex2", defaultValue: "\"I got great feedback from 9 people, but I can only think about the one negative comment.\""),
            String(localized: "trap_mental_filter_ex3", defaultValue: "\"The trip was amazing but I keep thinking about the one rainy day.\"")
        ]
        case .disqualifyingPositive: [
            String(localized: "trap_disqualifying_positive_ex", defaultValue: "\"They only said that to be nice. They didn't really mean it.\""),
            String(localized: "trap_disqualifying_positive_ex2", defaultValue: "\"I got the promotion, but it's only because nobody else wanted it.\""),
            String(localized: "trap_disqualifying_positive_ex3", defaultValue: "\"She smiled at me, but she probably does that with everyone.\"")
        ]
        case .jumpingToConclusions: [
            String(localized: "trap_jumping_conclusions_ex", defaultValue: "\"My friend didn't text back. They must be angry at me.\""),
            String(localized: "trap_jumping_conclusions_ex2", defaultValue: "\"My boss wants to meet. I'm definitely getting fired.\""),
            String(localized: "trap_jumping_conclusions_ex3", defaultValue: "\"They looked at me and whispered. They're talking about me.\"")
        ]
        case .magnification: [
            String(localized: "trap_magnification_ex", defaultValue: "\"I made a small mistake at work. I'll probably get fired.\""),
            String(localized: "trap_magnification_ex2", defaultValue: "\"I stuttered during the speech. Everyone thinks I'm incompetent.\""),
            String(localized: "trap_magnification_ex3", defaultValue: "\"I forgot their birthday. Our entire friendship is over.\"")
        ]
        case .emotionalReasoning: [
            String(localized: "trap_emotional_reasoning_ex", defaultValue: "\"I feel anxious about flying, so it must be dangerous.\""),
            String(localized: "trap_emotional_reasoning_ex2", defaultValue: "\"I feel guilty, so I must have done something wrong.\""),
            String(localized: "trap_emotional_reasoning_ex3", defaultValue: "\"I feel stupid, so I must actually be stupid.\"")
        ]
        case .shouldStatements: [
            String(localized: "trap_should_statements_ex", defaultValue: "\"I should always be productive. Resting means I'm lazy.\""),
            String(localized: "trap_should_statements_ex2", defaultValue: "\"I shouldn't feel sad. Other people have it worse.\""),
            String(localized: "trap_should_statements_ex3", defaultValue: "\"A good parent should never lose their patience.\"")
        ]
        case .labeling: [
            String(localized: "trap_labeling_ex", defaultValue: "\"I forgot to reply. I'm such a terrible person.\""),
            String(localized: "trap_labeling_ex2", defaultValue: "\"I didn't finish on time. I'm a total loser.\""),
            String(localized: "trap_labeling_ex3", defaultValue: "\"I made a mistake. I'm an idiot.\"")
        ]
        case .personalization: [
            String(localized: "trap_personalization_ex", defaultValue: "\"My team lost the project. It's all my fault.\""),
            String(localized: "trap_personalization_ex2", defaultValue: "\"My friend seems upset. I must have done something wrong.\""),
            String(localized: "trap_personalization_ex3", defaultValue: "\"The kids are struggling at school. I'm a bad parent.\"")
        ]
        }
    }

    /// Backwards compatibility
    var example: String {
        examples.first ?? ""
    }

    var howToSpot: String {
        switch self {
        case .allOrNothing:
            String(localized: "trap_spot_all_or_nothing", defaultValue: "Watch for words like \"always\" or \"never.\" If you only see two options, this trap may be active.")
        case .overgeneralization:
            String(localized: "trap_spot_overgeneralization", defaultValue: "Notice phrases like \"every time\" or \"nothing ever.\" One event is being turned into a universal rule.")
        case .mentalFilter:
            String(localized: "trap_spot_mental_filter", defaultValue: "Ask yourself: am I ignoring positive details and focusing only on the negative?")
        case .disqualifyingPositive:
            String(localized: "trap_spot_disqualifying_positive", defaultValue: "Notice if you're explaining away compliments or good outcomes with \"but\" or \"that doesn't count.\"")
        case .jumpingToConclusions:
            String(localized: "trap_spot_jumping_conclusions", defaultValue: "Are you assuming what others think or predicting the future without real evidence?")
        case .magnification:
            String(localized: "trap_spot_magnification", defaultValue: "Check if you're making a small problem feel enormous, or shrinking something positive.")
        case .emotionalReasoning:
            String(localized: "trap_spot_emotional_reasoning", defaultValue: "Ask: am I treating a feeling as proof? \"I feel it, so it must be true\" is a clue.")
        case .shouldStatements:
            String(localized: "trap_spot_should_statements", defaultValue: "Listen for \"should,\" \"must,\" or \"have to.\" These rigid rules create unnecessary pressure.")
        case .labeling:
            String(localized: "trap_spot_labeling", defaultValue: "Are you calling yourself a name instead of describing what happened? \"I'm a failure\" vs. \"I made a mistake.\"")
        case .personalization:
            String(localized: "trap_spot_personalization", defaultValue: "Check if you're taking responsibility for something that isn't entirely in your control.")
        }
    }

    var reframeSuggestions: [String] {
        switch self {
        case .allOrNothing: [
            String(localized: "reframe_all_or_nothing_1", defaultValue: "Maybe there's a middle ground between perfect and failure..."),
            String(localized: "reframe_all_or_nothing_2", defaultValue: "Progress matters, even if the result isn't flawless...")
        ]
        case .overgeneralization: [
            String(localized: "reframe_overgeneralization_1", defaultValue: "This is one situation, not a pattern that defines everything..."),
            String(localized: "reframe_overgeneralization_2", defaultValue: "One event doesn't determine the future...")
        ]
        case .mentalFilter: [
            String(localized: "reframe_mental_filter_1", defaultValue: "What positive details am I overlooking right now?"),
            String(localized: "reframe_mental_filter_2", defaultValue: "The full picture includes both good and bad parts...")
        ]
        case .disqualifyingPositive: [
            String(localized: "reframe_disqualifying_positive_1", defaultValue: "What if this compliment or success is genuine?"),
            String(localized: "reframe_disqualifying_positive_2", defaultValue: "Good things can happen because I deserve them...")
        ]
        case .jumpingToConclusions: [
            String(localized: "reframe_jumping_conclusions_1", defaultValue: "I don't actually know what they're thinking..."),
            String(localized: "reframe_jumping_conclusions_2", defaultValue: "There could be many explanations I haven't considered...")
        ]
        case .magnification: [
            String(localized: "reframe_magnification_1", defaultValue: "How big will this feel in a week? A month?"),
            String(localized: "reframe_magnification_2", defaultValue: "I'm making this bigger than it really is...")
        ]
        case .emotionalReasoning: [
            String(localized: "reframe_emotional_reasoning_1", defaultValue: "Feelings aren't facts — what does the evidence actually say?"),
            String(localized: "reframe_emotional_reasoning_2", defaultValue: "I feel this way, but that doesn't make it true...")
        ]
        case .shouldStatements: [
            String(localized: "reframe_should_statements_1", defaultValue: "It would be nice, but it's not a requirement..."),
            String(localized: "reframe_should_statements_2", defaultValue: "I can prefer this without demanding it of myself...")
        ]
        case .labeling: [
            String(localized: "reframe_labeling_1", defaultValue: "One action doesn't define who I am..."),
            String(localized: "reframe_labeling_2", defaultValue: "I made a mistake — that's different from being a mistake...")
        ]
        case .personalization: [
            String(localized: "reframe_personalization_1", defaultValue: "Many factors contributed to this, not just me..."),
            String(localized: "reframe_personalization_2", defaultValue: "I'm only responsible for what's within my control...")
        ]
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
