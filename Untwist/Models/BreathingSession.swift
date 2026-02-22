import Foundation
import SwiftData

@Model
final class BreathingSession {
    var id: UUID
    var date: Date
    var rounds: Int
    var duration: TimeInterval
    var createdAt: Date

    init(rounds: Int, duration: TimeInterval) {
        self.id = UUID()
        self.date = Date()
        self.rounds = rounds
        self.duration = duration
        self.createdAt = Date()
    }
}
