import Foundation
import SwiftUI

@MainActor
final class TodoListViewModel: ObservableObject {
    @Published private(set) var items: [TodoItem] = []
    @Published var selectedTab: Tab = .all
    private let storageKey = "todoListItems"
    private var cleanupTimer: Timer?
    
    var filteredItems: [TodoItem] {
        let sorted = items.sorted { $0.createdAt > $1.createdAt }
        switch selectedTab {
        case .all:
            return sorted.filter { !$0.isCompleted }
        case .flagged:
            return sorted.filter { $0.isFlagged && !$0.isCompleted }
        case .done:
            return sorted.filter { $0.isCompleted }
        }
    }
    
    init() {
        loadItems()
        setupCleanupTimer()
    }
    
    deinit {
        cleanupTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    func addItem(_ title: String) {
        let item = TodoItem(title: title)
        items.insert(item, at: 0)
        saveItems()
    }
    
    func toggleItem(_ item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
            if items[index].isCompleted {
                // Schedule removal from All list after 10 seconds
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(10))
                    if items[index].isCompleted {
                        items[index].completedAt = Date()
                        saveItems()
                    }
                }
            }
            saveItems()
        }
    }
    
    func toggleFlag(_ item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isFlagged.toggle()
            saveItems()
        }
    }
    
    // MARK: - Private Methods
    
    private func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([TodoItem].self, from: data)
        else { return }
        
        items = decoded
        cleanupCompletedTasks()
    }
    
    private func saveItems() {
        guard let encoded = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }
    
    private func setupCleanupTimer() {
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.cleanupCompletedTasks()
        }
    }
    
    private func cleanupCompletedTasks() {
        let now = Date()
        items.removeAll { item in
            guard let completedAt = item.completedAt else { return false }
            return now.timeIntervalSince(completedAt) >= 24 * 3600 // 24 hours
        }
        saveItems()
    }
}

// MARK: - Types

extension TodoListViewModel {
    enum Tab {
        case all
        case flagged
        case done
    }
} 