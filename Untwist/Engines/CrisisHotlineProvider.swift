import Foundation

enum CrisisHotlineProvider {

    // MARK: - Registry

    static let allHotlines: [CrisisHotline] = [
        // Turkey
        CrisisHotline(id: "tr_182", countryCode: "TR", number: "182", displayNumber: "182", nameKey: "crisis_182", nameDefault: "182 Suicide Prevention Line (TR)"),
        CrisisHotline(id: "tr_112", countryCode: "TR", number: "112", displayNumber: "112", nameKey: "crisis_tr_112", nameDefault: "112 Emergency Line (TR)"),
        // United States
        CrisisHotline(id: "us_988", countryCode: "US", number: "988", displayNumber: "988", nameKey: "crisis_988", nameDefault: "988 Suicide & Crisis Lifeline"),
        // United Kingdom
        CrisisHotline(id: "gb_116123", countryCode: "GB", number: "116123", displayNumber: "116 123", nameKey: "crisis_gb_116123", nameDefault: "116 123 Samaritans (UK)"),
        // Germany
        CrisisHotline(id: "de_08001110111", countryCode: "DE", number: "08001110111", displayNumber: "0800 111 0 111", nameKey: "crisis_de_tele", nameDefault: "Telefonseelsorge (DE)"),
        // France
        CrisisHotline(id: "fr_3114", countryCode: "FR", number: "3114", displayNumber: "3114", nameKey: "crisis_fr_3114", nameDefault: "3114 National Suicide Prevention (FR)"),
        // Canada
        CrisisHotline(id: "ca_988", countryCode: "CA", number: "988", displayNumber: "988", nameKey: "crisis_ca_988", nameDefault: "988 Suicide Crisis Helpline (CA)"),
        // Australia
        CrisisHotline(id: "au_131114", countryCode: "AU", number: "131114", displayNumber: "13 11 14", nameKey: "crisis_au_lifeline", nameDefault: "13 11 14 Lifeline (AU)"),
        // New Zealand
        CrisisHotline(id: "nz_1737", countryCode: "NZ", number: "1737", displayNumber: "1737", nameKey: "crisis_nz_1737", nameDefault: "1737 Need to Talk? (NZ)"),
        // Netherlands
        CrisisHotline(id: "nl_113", countryCode: "NL", number: "113", displayNumber: "113", nameKey: "crisis_nl_113", nameDefault: "113 Suicide Prevention (NL)"),
        // Belgium
        CrisisHotline(id: "be_1813", countryCode: "BE", number: "1813", displayNumber: "1813", nameKey: "crisis_be_1813", nameDefault: "1813 Suicide Line (BE)"),
        // Austria
        CrisisHotline(id: "at_142", countryCode: "AT", number: "142", displayNumber: "142", nameKey: "crisis_at_142", nameDefault: "142 Telefonseelsorge (AT)"),
        // Switzerland
        CrisisHotline(id: "ch_143", countryCode: "CH", number: "143", displayNumber: "143", nameKey: "crisis_ch_143", nameDefault: "143 Die Dargebotene Hand (CH)"),
        // Spain
        CrisisHotline(id: "es_024", countryCode: "ES", number: "024", displayNumber: "024", nameKey: "crisis_es_024", nameDefault: "024 Suicide Helpline (ES)"),
        // Italy
        CrisisHotline(id: "it_800860022", countryCode: "IT", number: "800860022", displayNumber: "800 86 00 22", nameKey: "crisis_it_telefono", nameDefault: "Telefono Amico (IT)"),
        // Sweden
        CrisisHotline(id: "se_90101", countryCode: "SE", number: "90101", displayNumber: "90101", nameKey: "crisis_se_90101", nameDefault: "90101 Mind (SE)"),
        // Japan
        CrisisHotline(id: "jp_0570064556", countryCode: "JP", number: "0570064556", displayNumber: "0570-064-556", nameKey: "crisis_jp_yorisoi", nameDefault: "Yorisoi Hotline (JP)"),
        // South Korea
        CrisisHotline(id: "kr_1393", countryCode: "KR", number: "1393", displayNumber: "1393", nameKey: "crisis_kr_1393", nameDefault: "1393 Suicide Prevention (KR)"),
        // Brazil
        CrisisHotline(id: "br_188", countryCode: "BR", number: "188", displayNumber: "188", nameKey: "crisis_br_188", nameDefault: "188 CVV (BR)"),
        // India
        CrisisHotline(id: "in_9820466726", countryCode: "IN", number: "9820466726", displayNumber: "9820466726", nameKey: "crisis_in_aasra", nameDefault: "iCall (IN)"),
    ]

    // MARK: - Locale Detection

    static var deviceCountryCode: String? {
        Locale.current.region?.identifier
    }

    static var localHotlines: [CrisisHotline] {
        guard let code = deviceCountryCode else { return [] }
        return allHotlines.filter { $0.countryCode == code }
    }

    static var otherHotlines: [CrisisHotline] {
        guard let code = deviceCountryCode else { return allHotlines }
        return allHotlines.filter { $0.countryCode != code }
    }

    // MARK: - Helpers

    static func flag(for countryCode: String) -> String {
        let base: UInt32 = 127397
        return String(countryCode.uppercased().unicodeScalars.compactMap {
            UnicodeScalar(base + $0.value)
        }.map { Character($0) })
    }

    static let findAHelplineURL = URL(string: "https://findahelpline.com")!
}
