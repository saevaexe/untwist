import Foundation

enum CrisisHotlineProvider {

    // MARK: - Registry

    static let allHotlines: [CrisisHotline] = [
        // Turkey
        hotline(
            id: "tr_182",
            countryCode: "TR",
            number: "182",
            displayNumber: "182",
            nameKey: "crisis_182",
            nameDefault: "182 MHRS Appointment Line (TR)",
            sourceURL: "https://www.saglik.gov.tr/TR-11686/alo-182---merkezi-hastane-randevu-sistemi.html",
            lastVerifiedAt: "2026-02-26"
        ),
        hotline(
            id: "tr_112",
            countryCode: "TR",
            number: "112",
            displayNumber: "112",
            nameKey: "crisis_tr_112",
            nameDefault: "112 Emergency Line (TR)",
            sourceURL: "https://www.112.gov.tr/",
            lastVerifiedAt: "2026-02-26"
        ),

        // United States
        hotline(
            id: "us_988",
            countryCode: "US",
            number: "988",
            displayNumber: "988",
            nameKey: "crisis_988",
            nameDefault: "988 Suicide & Crisis Lifeline",
            sourceURL: "https://988lifeline.org/"
        ),

        // United Kingdom
        hotline(
            id: "gb_116123",
            countryCode: "GB",
            number: "116123",
            displayNumber: "116 123",
            nameKey: "crisis_gb_116123",
            nameDefault: "116 123 Samaritans (UK)",
            sourceURL: "https://www.samaritans.org/how-we-can-help/contact-samaritan/"
        ),

        // Germany
        hotline(
            id: "de_08001110111",
            countryCode: "DE",
            number: "08001110111",
            displayNumber: "0800 111 0 111",
            nameKey: "crisis_de_tele",
            nameDefault: "Telefonseelsorge (DE)",
            sourceURL: "https://www.telefonseelsorge.de/"
        ),

        // France
        hotline(
            id: "fr_3114",
            countryCode: "FR",
            number: "3114",
            displayNumber: "3114",
            nameKey: "crisis_fr_3114",
            nameDefault: "3114 National Suicide Prevention (FR)",
            sourceURL: "https://www.3114.fr/"
        ),

        // Canada
        hotline(
            id: "ca_988",
            countryCode: "CA",
            number: "988",
            displayNumber: "988",
            nameKey: "crisis_ca_988",
            nameDefault: "988 Suicide Crisis Helpline (CA)",
            sourceURL: "https://988.ca/"
        ),

        // Australia
        hotline(
            id: "au_131114",
            countryCode: "AU",
            number: "131114",
            displayNumber: "13 11 14",
            nameKey: "crisis_au_lifeline",
            nameDefault: "13 11 14 Lifeline (AU)",
            sourceURL: "https://www.lifeline.org.au/"
        ),

        // New Zealand
        hotline(
            id: "nz_1737",
            countryCode: "NZ",
            number: "1737",
            displayNumber: "1737",
            nameKey: "crisis_nz_1737",
            nameDefault: "1737 Need to Talk? (NZ)",
            sourceURL: "https://1737.org.nz/"
        ),

        // Netherlands
        hotline(
            id: "nl_113",
            countryCode: "NL",
            number: "113",
            displayNumber: "113",
            nameKey: "crisis_nl_113",
            nameDefault: "113 Suicide Prevention (NL)",
            sourceURL: "https://www.113.nl/"
        ),

        // Belgium
        hotline(
            id: "be_1813",
            countryCode: "BE",
            number: "1813",
            displayNumber: "1813",
            nameKey: "crisis_be_1813",
            nameDefault: "1813 Suicide Line (BE)",
            sourceURL: "https://www.zelfmoord1813.be/"
        ),

        // Austria
        hotline(
            id: "at_142",
            countryCode: "AT",
            number: "142",
            displayNumber: "142",
            nameKey: "crisis_at_142",
            nameDefault: "142 Telefonseelsorge (AT)",
            sourceURL: "https://www.telefonseelsorge.at/"
        ),

        // Switzerland
        hotline(
            id: "ch_143",
            countryCode: "CH",
            number: "143",
            displayNumber: "143",
            nameKey: "crisis_ch_143",
            nameDefault: "143 Die Dargebotene Hand (CH)",
            sourceURL: "https://www.143.ch/"
        ),

        // Spain
        hotline(
            id: "es_024",
            countryCode: "ES",
            number: "024",
            displayNumber: "024",
            nameKey: "crisis_es_024",
            nameDefault: "024 Suicide Helpline (ES)",
            sourceURL: "https://findahelpline.com/"
        ),

        // Italy
        hotline(
            id: "it_800860022",
            countryCode: "IT",
            number: "800860022",
            displayNumber: "800 86 00 22",
            nameKey: "crisis_it_telefono",
            nameDefault: "Telefono Amico (IT)",
            sourceURL: "https://www.telefonoamico.it/"
        ),

        // Sweden
        hotline(
            id: "se_90101",
            countryCode: "SE",
            number: "90101",
            displayNumber: "90101",
            nameKey: "crisis_se_90101",
            nameDefault: "90101 Mind (SE)",
            sourceURL: "https://mind.se/"
        ),

        // Japan
        hotline(
            id: "jp_0570064556",
            countryCode: "JP",
            number: "0570064556",
            displayNumber: "0570-064-556",
            nameKey: "crisis_jp_yorisoi",
            nameDefault: "Yorisoi Hotline (JP)",
            sourceURL: "https://findahelpline.com/"
        ),

        // South Korea
        hotline(
            id: "kr_1393",
            countryCode: "KR",
            number: "1393",
            displayNumber: "1393",
            nameKey: "crisis_kr_1393",
            nameDefault: "1393 Suicide Prevention (KR)",
            sourceURL: "https://findahelpline.com/"
        ),

        // Brazil
        hotline(
            id: "br_188",
            countryCode: "BR",
            number: "188",
            displayNumber: "188",
            nameKey: "crisis_br_188",
            nameDefault: "188 CVV (BR)",
            sourceURL: "https://www.cvv.org.br/"
        ),

        // India
        hotline(
            id: "in_912227546669",
            countryCode: "IN",
            number: "+912227546669",
            displayNumber: "+91 22 2754 6669",
            nameKey: "crisis_in_aasra",
            nameDefault: "AASRA Suicide Prevention (IN)",
            sourceURL: "https://aasra.info/",
            lastVerifiedAt: "2026-02-26"
        ),
    ]

    static var supportedCountryCodes: [String] {
        Array(Set(allHotlines.map(\.countryCode))).sorted()
    }

    // MARK: - Locale Detection

    static var deviceCountryCode: String? {
        countryCode(from: .current)
    }

    static var localHotlines: [CrisisHotline] {
        localHotlines(for: deviceCountryCode)
    }

    static var otherHotlines: [CrisisHotline] {
        otherHotlines(for: deviceCountryCode)
    }

    static func countryCode(from locale: Locale) -> String? {
        if let regionIdentifier = locale.region?.identifier {
            return regionIdentifier
        }
        return locale.regionCode
    }

    static func resolvedCountryCode(overrideCode: String?, locale: Locale = .current) -> String? {
        if let code = normalizedCountryCode(overrideCode), supportedCountryCodes.contains(code) {
            return code
        }
        return countryCode(from: locale)
    }

    static func localHotlines(for countryCode: String?) -> [CrisisHotline] {
        guard let code = normalizedCountryCode(countryCode) else { return [] }
        return allHotlines.filter { $0.countryCode == code }
    }

    static func otherHotlines(for countryCode: String?) -> [CrisisHotline] {
        guard let code = normalizedCountryCode(countryCode) else { return allHotlines }
        return allHotlines.filter { $0.countryCode != code }
    }

    static func countryName(for countryCode: String, locale: Locale = .current) -> String {
        locale.localizedString(forRegionCode: countryCode) ?? countryCode
    }

    // MARK: - Helpers

    static func flag(for countryCode: String) -> String {
        let base: UInt32 = 127397
        return String(countryCode.uppercased().unicodeScalars.compactMap {
            UnicodeScalar(base + $0.value)
        }.map { Character($0) })
    }

    static let findAHelplineURL = URL(string: "https://findahelpline.com")!

    private static func hotline(
        id: String,
        countryCode: String,
        number: String,
        displayNumber: String,
        nameKey: String,
        nameDefault: String,
        sourceURL: String? = nil,
        lastVerifiedAt: String? = nil
    ) -> CrisisHotline {
        CrisisHotline(
            id: id,
            countryCode: countryCode,
            number: number,
            displayNumber: displayNumber,
            nameKey: nameKey,
            nameDefault: nameDefault,
            sourceURL: sourceURL.flatMap(URL.init(string:)),
            lastVerifiedAt: lastVerifiedAt
        )
    }

    private static func normalizedCountryCode(_ countryCode: String?) -> String? {
        guard let countryCode else { return nil }
        let trimmed = countryCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return trimmed.uppercased()
    }
}
