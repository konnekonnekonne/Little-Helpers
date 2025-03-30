import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Filter Toggle
                    Toggle("Show Favorites Only", isOn: $viewModel.showFavoritesOnly)
                        .padding(.horizontal)
                    
                    // Apps Grid
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.filteredApps) { app in
                            MicroAppCard(app: app)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Little Helpers")
        }
    }
}

struct MicroAppCard: View {
    let app: MicroApp
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var showingApp = false
    
    var body: some View {
        VStack {
            Image(systemName: app.icon)
                .font(.system(size: 40))
                .foregroundColor(.accentColor)
                .frame(width: 60, height: 60)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(Circle())
            
            Text(app.name)
                .font(.headline)
            
            Text(app.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
            
            if app.isPurchased {
                NavigationLink(isActive: $showingApp) {
                    if app.id == "costSplit" {
                        CostSplitView()
                    }
                } label: {
                    Text("Open")
                }
                .buttonStyle(.borderedProminent)
            } else if !app.hasTried {
                Button("Try Once") {
                    viewModel.tryApp(app)
                    showingApp = true
                }
                .buttonStyle(.bordered)
            } else {
                Button(String(format: "Buy €%.2f", (app.price as NSDecimalNumber).doubleValue)) {
                    viewModel.purchaseApp(app)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppViewModel())
} 