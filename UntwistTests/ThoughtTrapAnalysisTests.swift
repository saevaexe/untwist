import Testing
import Foundation
@testable import Untwist

struct ThoughtTrapAnalysisTests {

    private let enLocale = Locale(identifier: "en")
    private let trLocale = Locale(identifier: "tr")

    @Test func analyzeReturnsEmptyForBenignText() {
        let results = ThoughtTrapEngine.analyze("I went for a nice walk today", locale: enLocale)
        #expect(results.isEmpty)
    }

    @Test func analyzeDetectsAllOrNothing() {
        let results = ThoughtTrapEngine.analyze("I always fail at everything, it's completely ruined", locale: enLocale)
        let traps = results.map(\.trap)
        #expect(traps.contains(.allOrNothing))
    }

    @Test func analyzeDetectsShouldStatements() {
        let results = ThoughtTrapEngine.analyze("I should be more productive, I must work harder", locale: enLocale)
        let traps = results.map(\.trap)
        #expect(traps.contains(.shouldStatements))
    }

    @Test func analyzeDetectsLabeling() {
        let results = ThoughtTrapEngine.analyze("I'm such a stupid idiot loser", locale: enLocale)
        let traps = results.map(\.trap)
        #expect(traps.contains(.labeling))
    }

    @Test func analyzeScoresSortedHighestFirst() {
        // Use many keywords from allOrNothing to get a high score
        let results = ThoughtTrapEngine.analyze("I always fail, it's completely impossible, everything is totally ruined", locale: enLocale)
        guard results.count >= 2 else {
            // At least one trap should be detected with multiple keywords
            #expect(!results.isEmpty)
            return
        }
        #expect(results[0].score >= results[1].score)
    }

    @Test func analyzeFiltersBelowThreshold() {
        let results = ThoughtTrapEngine.analyze("maybe something happened", locale: enLocale)
        // All scores should be >= 0.3
        for result in results {
            #expect(result.score >= 0.3)
        }
    }

    @Test func analyzeTurkishKeywords() {
        let results = ThoughtTrapEngine.analyze("hep başarısız oluyorum, hiçbir şey yolunda gitmiyor", locale: trLocale)
        #expect(!results.isEmpty)
    }
}
