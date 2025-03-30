import Foundation

/// A preset for the fitness timer with interval, break, and rounds configuration
struct TimerPreset: Codable, Identifiable, Hashable {
    // MARK: - Properties
    
    let id: UUID
    var name: String
    var intervalDuration: TimeInterval
    var breakDuration: TimeInterval
    var rounds: Int
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        name: String,
        intervalDuration: TimeInterval,
        breakDuration: TimeInterval,
        rounds: Int
    ) {
        self.id = id
        self.name = name
        self.intervalDuration = intervalDuration
        self.breakDuration = breakDuration
        self.rounds = rounds
    }
} 