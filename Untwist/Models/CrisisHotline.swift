import Foundation

struct CrisisHotline: Identifiable, Hashable {
    let id: String
    let countryCode: String
    let number: String
    let displayNumber: String
    let nameKey: String
    let nameDefault: String

    var phoneURL: URL? {
        URL(string: "tel://\(number.filter { $0.isNumber })")
    }
}
