import CoreHaptics
import UIKit

final class BreathingHapticEngine {
    private var engine: CHHapticEngine?
    private var player: CHHapticAdvancedPatternPlayer?
    private let reduceMotion: Bool

    static var supportsHaptics: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    init(reduceMotion: Bool) {
        self.reduceMotion = reduceMotion
    }

    func prepare() {
        guard Self.supportsHaptics, !reduceMotion else { return }
        do {
            engine = try CHHapticEngine()
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            engine?.stoppedHandler = { _ in }
            try engine?.start()
        } catch {
            engine = nil
        }
    }

    // MARK: - Phase Haptics

    func playInhale(duration: Double) {
        guard let engine, !reduceMotion else { return }
        stopCurrentPlayer()

        do {
            let steps = 6
            var events: [CHHapticEvent] = []
            let stepDuration = duration / Double(steps)

            for i in 0..<steps {
                let intensity = 0.2 + (0.5 * Double(i) / Double(steps - 1))
                let params = [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensity)),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ]
                let event = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: params,
                    relativeTime: stepDuration * Double(i),
                    duration: stepDuration
                )
                events.append(event)
            }

            let pattern = try CHHapticPattern(events: events, parameters: [])
            player = try engine.makeAdvancedPlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {}
    }

    func playHold(duration: Double) {
        guard let engine, !reduceMotion else { return }
        stopCurrentPlayer()

        do {
            var events: [CHHapticEvent] = []
            let pulseInterval = 1.0
            let pulseCount = Int(duration / pulseInterval)

            for i in 0..<pulseCount {
                let params = [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ]
                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: params,
                    relativeTime: pulseInterval * Double(i)
                )
                events.append(event)
            }

            let pattern = try CHHapticPattern(events: events, parameters: [])
            player = try engine.makeAdvancedPlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {}
    }

    func playExhale(duration: Double) {
        guard let engine, !reduceMotion else { return }
        stopCurrentPlayer()

        do {
            let steps = 6
            var events: [CHHapticEvent] = []
            let stepDuration = duration / Double(steps)

            for i in 0..<steps {
                let intensity = 0.7 - (0.6 * Double(i) / Double(steps - 1))
                let params = [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensity)),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.15)
                ]
                let event = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: params,
                    relativeTime: stepDuration * Double(i),
                    duration: stepDuration
                )
                events.append(event)
            }

            let pattern = try CHHapticPattern(events: events, parameters: [])
            player = try engine.makeAdvancedPlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {}
    }

    func playRoundComplete() {
        guard let engine, !reduceMotion else { return }
        stopCurrentPlayer()

        do {
            let params1 = [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
            ]
            let params2 = [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
            ]
            let events = [
                CHHapticEvent(eventType: .hapticTransient, parameters: params1, relativeTime: 0),
                CHHapticEvent(eventType: .hapticTransient, parameters: params2, relativeTime: 0.12)
            ]

            let pattern = try CHHapticPattern(events: events, parameters: [])
            player = try engine.makeAdvancedPlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {}
    }

    // MARK: - Lifecycle

    func stop() {
        stopCurrentPlayer()
    }

    func tearDown() {
        stopCurrentPlayer()
        engine?.stop()
        engine = nil
    }

    private func stopCurrentPlayer() {
        try? player?.stop(atTime: CHHapticTimeImmediate)
        player = nil
    }
}
