import SwiftUI

/// Coordinator for the FitnessTimer helper
/// Manages navigation and initialization of the helper
@MainActor
final class FitnessTimerCoordinator: ObservableObject {
    // MARK: - Properties
    
    @Published private(set) var viewModel: FitnessTimerViewModel
    
    // MARK: - Initialization
    
    init() {
        self.viewModel = FitnessTimerViewModel()
    }
    
    // MARK: - Navigation
    
    @ViewBuilder
    func makeRootView() -> some View {
        FitnessTimerView(viewModel: viewModel)
    }
} 