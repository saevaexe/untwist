import Testing
import Foundation
@testable import Untwist

struct CrisisDetectionTests {

    // MARK: - English Keywords

    @Test func detectsEnglishCrisisKeywords() {
        #expect(ThoughtTrapEngine.detectCrisis("I want to kill myself"))
        #expect(ThoughtTrapEngine.detectCrisis("I want to die"))
        #expect(ThoughtTrapEngine.detectCrisis("thinking about suicide"))
        #expect(ThoughtTrapEngine.detectCrisis("I'm better off dead"))
        #expect(ThoughtTrapEngine.detectCrisis("I want to end my life"))
        #expect(ThoughtTrapEngine.detectCrisis("I don't want to live anymore"))
        #expect(ThoughtTrapEngine.detectCrisis("no reason to live"))
        #expect(ThoughtTrapEngine.detectCrisis("I can't go on"))
        #expect(ThoughtTrapEngine.detectCrisis("I want to end it all"))
    }

    // MARK: - Turkish Keywords

    @Test func detectsTurkishCrisisKeywords() {
        #expect(ThoughtTrapEngine.detectCrisis("kendimi öldürmek istiyorum"))
        #expect(ThoughtTrapEngine.detectCrisis("ölmek istiyorum"))
        #expect(ThoughtTrapEngine.detectCrisis("yaşamak istemiyorum"))
        #expect(ThoughtTrapEngine.detectCrisis("intihar etmeyi düşünüyorum"))
        #expect(ThoughtTrapEngine.detectCrisis("hayatıma son vermek istiyorum"))
        #expect(ThoughtTrapEngine.detectCrisis("yaşamanın anlamı yok"))
        #expect(ThoughtTrapEngine.detectCrisis("ölsem daha iyi"))
        #expect(ThoughtTrapEngine.detectCrisis("artık dayanamıyorum"))
        #expect(ThoughtTrapEngine.detectCrisis("her şeyi bitirmek istiyorum"))
    }

    // MARK: - Case Insensitivity

    @Test func caseInsensitive() {
        #expect(ThoughtTrapEngine.detectCrisis("I WANT TO KILL MYSELF"))
        #expect(ThoughtTrapEngine.detectCrisis("SUICIDE"))
        #expect(ThoughtTrapEngine.detectCrisis("İNTİHAR"))
    }

    // MARK: - Dual Locale (TR text on EN device, EN text on TR device)

    @Test func turkishTextOnEnglishLocale() {
        let enLocale = Locale(identifier: "en")
        #expect(ThoughtTrapEngine.detectCrisis("intihar etmek istiyorum", locale: enLocale))
        #expect(ThoughtTrapEngine.detectCrisis("kendimi öldürmek istiyorum", locale: enLocale))
    }

    @Test func englishTextOnTurkishLocale() {
        let trLocale = Locale(identifier: "tr")
        #expect(ThoughtTrapEngine.detectCrisis("I want to kill myself", locale: trLocale))
        #expect(ThoughtTrapEngine.detectCrisis("suicide", locale: trLocale))
    }

    // MARK: - Diacritics Resistance

    @Test func diacriticsNormalization() {
        // Stripped diacritics should still match
        #expect(ThoughtTrapEngine.detectCrisis("kendimi oldur"))
        #expect(ThoughtTrapEngine.detectCrisis("olmek istiyorum"))
    }

    // MARK: - No False Positives

    @Test func benignTextDoesNotTrigger() {
        #expect(!ThoughtTrapEngine.detectCrisis("I had a bad day at work"))
        #expect(!ThoughtTrapEngine.detectCrisis("I feel sad and anxious"))
        #expect(!ThoughtTrapEngine.detectCrisis("Nobody likes me"))
        #expect(!ThoughtTrapEngine.detectCrisis("I'm worthless"))
        #expect(!ThoughtTrapEngine.detectCrisis("Everything is terrible"))
        #expect(!ThoughtTrapEngine.detectCrisis("I failed the exam again"))
        #expect(!ThoughtTrapEngine.detectCrisis("Bugün çok kötü bir gün geçirdim"))
        #expect(!ThoughtTrapEngine.detectCrisis("Kimse beni sevmiyor"))
        #expect(!ThoughtTrapEngine.detectCrisis("Hiçbir şey yolunda gitmiyor"))
    }

    // MARK: - Empty and Edge Cases

    @Test func emptyTextDoesNotTrigger() {
        #expect(!ThoughtTrapEngine.detectCrisis(""))
        #expect(!ThoughtTrapEngine.detectCrisis("   "))
    }

    @Test func partialKeywordsDoNotTrigger() {
        // "die" alone is not a keyword, "want to die" is
        #expect(!ThoughtTrapEngine.detectCrisis("the die is cast"))
        // "kill" alone is not a keyword, "kill myself" is
        #expect(!ThoughtTrapEngine.detectCrisis("kill the process"))
    }
}
