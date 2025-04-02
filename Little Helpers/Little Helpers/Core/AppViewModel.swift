import Foundation
import SwiftUI

@MainActor
class AppViewModel: ObservableObject {
    @Published var microApps: [MicroApp]
    @Published var selectedTab: Tab = .home
    
    init() {
        self.microApps = MicroApp.allApps
    }
    
    enum Tab {
        case home
        case settings
    }
} 