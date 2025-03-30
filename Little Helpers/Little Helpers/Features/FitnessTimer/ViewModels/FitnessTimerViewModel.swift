import SwiftUI
import Foundation
import AVFoundation

/// ViewModel for the FitnessTimer helper
@MainActor
final class FitnessTimerViewModel: ObservableObject {
    // MARK: - Constants
    
    private enum Constants {
        static let storageKey = "fitness_timer_presets"
    }
    
    // MARK: - Published Properties
    
    @Published private(set) var isRunning = false
    @Published private(set) var remainingTime: TimeInterval = 0
    @Published private(set) var currentRound = 1
    @Published private(set) var totalRounds = 1
    @Published private(set) var isBreak = false
    @Published private(set) var presets: [TimerPreset] = []
    
    // MARK: - Public Properties
    
    private(set) var intervalDuration: TimeInterval = 0
    private(set) var breakDuration: TimeInterval = 0
    
    // MARK: - Private Properties
    
    private var timer: Timer?
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var lastBeepTime: TimeInterval = 0
    
    // MARK: - Initialization
    
    init() {
        setupAudioPlayers()
        loadPresets()
    }
    
    // MARK: - Audio Setup
    
    private func setupAudioPlayers() {
        print("Setting up audio players...")
        // Setup audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session setup successful")
        } catch {
            print("Failed to setup audio session: \(error)")
        }
        
        // Load audio files
        if let letsGoUrl = Bundle.main.url(forResource: "lets_go", withExtension: "m4a") {
            print("Found lets_go.m4a at: \(letsGoUrl)")
            do {
                let player = try AVAudioPlayer(contentsOf: letsGoUrl)
                player.prepareToPlay() // Preload the audio
                player.volume = 1.0
                audioPlayers["lets_go"] = player
                print("Successfully created player for lets_go")
            } catch {
                print("Failed to create player for lets_go: \(error)")
            }
        } else {
            print("Could not find lets_go.m4a")
        }
        
        if let pauseUrl = Bundle.main.url(forResource: "pause", withExtension: "m4a") {
            print("Found pause.m4a at: \(pauseUrl)")
            do {
                let player = try AVAudioPlayer(contentsOf: pauseUrl)
                player.prepareToPlay() // Preload the audio
                player.volume = 1.0
                audioPlayers["pause"] = player
                print("Successfully created player for pause")
            } catch {
                print("Failed to create player for pause: \(error)")
            }
        } else {
            print("Could not find pause.m4a")
        }
        
        if let beepUrl = Bundle.main.url(forResource: "beep", withExtension: "m4a") {
            print("Found beep.m4a at: \(beepUrl)")
            do {
                let player = try AVAudioPlayer(contentsOf: beepUrl)
                player.prepareToPlay() // Preload the audio
                player.volume = 0.7 // Slightly lower volume for the beep
                audioPlayers["beep"] = player
                print("Successfully created player for beep")
            } catch {
                print("Failed to create player for beep: \(error)")
            }
        } else {
            print("Could not find beep.m4a")
        }
    }
    
    private func playSound(_ name: String) {
        print("Attempting to play sound: \(name)")
        if let player = audioPlayers[name] {
            player.currentTime = 0 // Reset to start
            if player.play() {
                print("Successfully started playing \(name)")
            } else {
                print("Failed to play \(name)")
                // Try to recover the player
                player.prepareToPlay()
                _ = player.play()
            }
        } else {
            print("No audio player found for \(name)")
        }
    }
    
    // MARK: - Public Methods
    
    func startTimer(intervalDuration: TimeInterval, breakDuration: TimeInterval, rounds: Int) {
        self.intervalDuration = intervalDuration
        self.breakDuration = breakDuration
        self.totalRounds = rounds
        self.currentRound = 1
        self.isBreak = false
        self.remainingTime = intervalDuration
        
        startPhase()
    }
    
    func startPreset(_ preset: TimerPreset) {
        startTimer(
            intervalDuration: preset.intervalDuration,
            breakDuration: preset.breakDuration,
            rounds: preset.rounds
        )
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resumeTimer() {
        startPhase()
    }
    
    func stopTimer() {
        pauseTimer()
        remainingTime = 0
        currentRound = 1
        isBreak = false
    }
    
    func addPreset(_ preset: TimerPreset) {
        presets.append(preset)
        savePresets()
    }
    
    func removePreset(at index: Int) {
        presets.remove(at: index)
        savePresets()
    }
    
    // MARK: - Private Methods
    
    private func startPhase() {
        isRunning = true
        lastBeepTime = remainingTime
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTimer()
            }
        }
    }
    
    private func updateTimer() {
        guard isRunning else { return }
        
        // Play countdown beeps
        if remainingTime <= 5 && remainingTime > 0 {
            let currentSecond = floor(remainingTime)
            if currentSecond < floor(lastBeepTime) {
                playSound("beep")
            }
            lastBeepTime = remainingTime
        }
        
        remainingTime -= 0.1
        
        if remainingTime <= 0 {
            if isBreak {
                if currentRound < totalRounds {
                    currentRound += 1
                    isBreak = false
                    remainingTime = intervalDuration
                    playSound("lets_go")
                } else {
                    stopTimer()
                    return
                }
            } else {
                isBreak = true
                remainingTime = breakDuration
                playSound("pause")
            }
            startPhase()
        }
    }
    
    private func loadPresets() {
        if let data = UserDefaults.standard.data(forKey: Constants.storageKey),
           let decodedPresets = try? JSONDecoder().decode([TimerPreset].self, from: data) {
            presets = decodedPresets
        }
    }
    
    private func savePresets() {
        if let encoded = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(encoded, forKey: Constants.storageKey)
        }
    }
} 