import Foundation
import Testing
@testable import Untwist

struct CrisisHotlineProviderTests {

    @Test func localHotlinesReturnedForKnownCountry() {
        let trHotlines = CrisisHotlineProvider.localHotlines(for: "TR")

        #expect(!trHotlines.isEmpty)
        #expect(trHotlines.allSatisfy { $0.countryCode == "TR" })
    }

    @Test func unknownCountryFallsBackToFindAllOtherHotlines() {
        let local = CrisisHotlineProvider.localHotlines(for: "ZZ")
        let other = CrisisHotlineProvider.otherHotlines(for: "ZZ")

        #expect(local.isEmpty)
        #expect(other.count == CrisisHotlineProvider.allHotlines.count)
    }

    @Test func supportedManualOverrideTakesPriority() {
        let locale = Locale(identifier: "tr_TR")
        let resolved = CrisisHotlineProvider.resolvedCountryCode(overrideCode: "US", locale: locale)

        #expect(resolved == "US")
    }

    @Test func invalidManualOverrideFallsBackToLocale() {
        let locale = Locale(identifier: "en_GB")
        let resolved = CrisisHotlineProvider.resolvedCountryCode(overrideCode: "ZZ", locale: locale)

        #expect(resolved == "GB")
    }

    @Test func internationalNumbersKeepPlusPrefix() {
        let indiaHotline = CrisisHotlineProvider.allHotlines.first { $0.id == "in_912227546669" }

        #expect(indiaHotline != nil)
        #expect(indiaHotline?.phoneURL?.absoluteString.contains("+912227546669") == true)
    }

    @Test func criticalHotlinesHaveVerificationMetadata() {
        let turkeyEmergency = CrisisHotlineProvider.allHotlines.first { $0.id == "tr_112" }
        let indiaAasra = CrisisHotlineProvider.allHotlines.first { $0.id == "in_912227546669" }

        #expect(turkeyEmergency?.sourceURL != nil)
        #expect(turkeyEmergency?.lastVerifiedAt == "2026-02-26")
        #expect(indiaAasra?.sourceURL != nil)
        #expect(indiaAasra?.lastVerifiedAt == "2026-02-26")
    }
}
