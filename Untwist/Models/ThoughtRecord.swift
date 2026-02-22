import Foundation
import SwiftData

@Model
final class ThoughtRecord {
    var id: UUID
    var date: Date
    var event: String
    var automaticThought: String
    var moodBefore: Int // 0-100
    var moodAfter: Int // 0-100
    var selectedTraps: [ThoughtTrapType]
    var alternativeThought: String
    var createdAt: Date

    init(
        event: String,
        automaticThought: String,
        moodBefore: Int,
        moodAfter: Int,
        selectedTraps: [ThoughtTrapType],
        alternativeThought: String
    ) {
        self.id = UUID()
        self.date = Date()
        self.event = event
        self.automaticThought = automaticThought
        self.moodBefore = moodBefore
        self.moodAfter = moodAfter
        self.selectedTraps = selectedTraps
        self.alternativeThought = alternativeThought
        self.createdAt = Date()
    }
}
