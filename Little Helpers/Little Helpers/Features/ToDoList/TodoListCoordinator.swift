import SwiftUI

/// Coordinator for the ToDoList helper
/// Manages navigation and initialization of the helper
@MainActor
final class TodoListCoordinator: ObservableObject {
    // MARK: - Properties
    
    @Published private(set) var viewModel: TodoListViewModel
    
    // MARK: - Initialization
    
    init() {
        self.viewModel = TodoListViewModel()
    }
    
    // MARK: - Navigation
    
    @ViewBuilder
    func makeRootView() -> some View {
        TodoListView(viewModel: viewModel)
    }
} 