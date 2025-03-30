//
//  Little_HelpersApp.swift
//  Little Helpers
//
//  Created by Konstantin Escher on 30.03.25.
//

import SwiftUI

@main
struct Little_HelpersApp: App {
    @StateObject private var viewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(viewModel)
        }
    }
}
