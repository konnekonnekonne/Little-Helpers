import Foundation
import SwiftUI

@MainActor
class AppViewModel: ObservableObject {
    @Published var microApps: [MicroApp] = MicroApp.allApps
    @Published var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case settings
    }
} 