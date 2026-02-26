import Foundation

struct CrisisHotline: Identifiable, Hashable {
    let id: String
    let countryCode: String
    let number: String
    let displayNumber: String
    let nameKey: String
    let nameDefault: String
    let sourceURL: URL?
    let lastVerifiedAt: String?

    var phoneURL: URL? {
        let hasLeadingPlus = number.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("+")
        let digits = number.filter(\.isNumber)
        let dialValue = hasLeadingPlus ? "+\(digits)" : digits
        guard !dialValue.isEmpty else { return nil }
        return URL(string: "tel://\(dialValue)")
    }
}
