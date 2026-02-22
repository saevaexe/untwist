import Foundation
import SwiftData

@Model
final class MoodEntry {
    var id: UUID
    var date: Date
    var score: Int // 0-100
    var note: String?
    var createdAt: Date

    init(score: Int, note: String? = nil) {
        self.id = UUID()
        self.date = Date()
        self.score = score
        self.note = note
        self.createdAt = Date()
    }
}
