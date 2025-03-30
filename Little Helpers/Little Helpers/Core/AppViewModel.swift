import Foundation
import SwiftUI

@MainActor
class AppViewModel: ObservableObject {
    @Published var microApps: [MicroApp] = MicroApp.allApps
    @Published var showFavoritesOnly: Bool = false
    @Published var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case settings
    }
    
    var filteredApps: [MicroApp] {
        if showFavoritesOnly {
            return microApps.filter { $0.isPurchased }
        }
        return microApps
    }
    
    func toggleFavorite() {
        showFavoritesOnly.toggle()
    }
    
    func tryApp(_ app: MicroApp) {
        if let index = microApps.firstIndex(where: { $0.id == app.id }) {
            microApps[index].hasTried = true
        }
    }
    
    func purchaseApp(_ app: MicroApp) {
        if let index = microApps.firstIndex(where: { $0.id == app.id }) {
            microApps[index].isPurchased = true
        }
    }
} 