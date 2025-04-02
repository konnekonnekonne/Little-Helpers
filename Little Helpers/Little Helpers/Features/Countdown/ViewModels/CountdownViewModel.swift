import Foundation
import Combine
import SwiftUI

@MainActor
class CountdownViewModel: ObservableObject {
    @Published var events: [CountdownEvent] = []
    @Published var showingAddEvent = false
    @Published var currentTime = Date()
    
    private var timerCancellable: AnyCancellable?
    private let userDefaults = UserDefaults.standard
    private let eventsKey = "countdownEvents"
    
    init() {
        loadEvents()
        startTimer()
    }
    
    private func startTimer() {
        // Update every second for smoother countdown experience
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.currentTime = Date()
                self?.objectWillChange.send()
            }
    }
    
    func addEvent(_ event: CountdownEvent) {
        events.append(event)
        saveEvents()
    }
    
    func deleteEvent(at offsets: IndexSet) {
        events.remove(atOffsets: offsets)
        saveEvents()
    }
    
    func deleteEvent(_ event: CountdownEvent) {
        events.removeAll { $0.id == event.id }
        saveEvents()
    }
    
    func moveEvent(from source: IndexSet, to destination: Int) {
        withAnimation {
            events.move(fromOffsets: source, toOffset: destination)
            saveEvents()
        }
    }
    
    private func loadEvents() {
        guard let data = userDefaults.data(forKey: eventsKey),
              let savedEvents = try? JSONDecoder().decode([CountdownEvent].self, from: data) else {
            return
        }
        self.events = savedEvents
    }
    
    private func saveEvents() {
        guard let data = try? JSONEncoder().encode(events) else { return }
        userDefaults.set(data, forKey: eventsKey)
    }
    
    deinit {
        timerCancellable?.cancel()
    }
} 