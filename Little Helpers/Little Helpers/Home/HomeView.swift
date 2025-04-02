import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = AppViewModel()
    @State private var searchText = ""
    
    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 180), spacing: 16)
    ]
    
    var filteredApps: [MicroApp] {
        if searchText.isEmpty {
            return viewModel.microApps
        }
        return viewModel.microApps.filter { app in
            app.name.localizedCaseInsensitiveContains(searchText) ||
            app.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Welcome Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(.title2)
                            .fontWeight(.medium)
                        Text("Find the right helper for your task")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search helpers", text: $searchText)
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Grid of Helpers
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredApps) { app in
                            MicroAppCard(app: app)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal)
                    .animation(.spring(duration: 0.3), value: filteredApps)
                }
                .padding(.vertical, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Little Helpers")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "👋 Good morning"
        case 12..<17: return "👋 Good afternoon"
        default: return "👋 Good evening"
        }
    }
}

struct MicroAppCard: View {
    let app: MicroApp
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationLink {
            switch app.id {
            case "costSplit":
                CostSplitView()
            case "fitnessTimer":
                FitnessTimerCoordinator().makeRootView()
            case "toDoList":
                TodoListCoordinator().makeRootView()
            case "unitConverter":
                UnitConverterView()
            case "countdown":
                CountdownView()
            case "tipCalculator":
                TipCalculatorView()
            default:
                EmptyView()
            }
        } label: {
            VStack(spacing: 16) {
                // Icon
                Image(systemName: app.icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.linearGradient(
                        colors: [.accentColor, .accentColor.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 56, height: 56)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(color: .accentColor.opacity(0.2), radius: 8, x: 0, y: 4)
                
                // Text Content
                VStack(spacing: 4) {
                    Text(app.name)
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                    
                    Text(app.description)
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.background)
                    .shadow(color: Color(.systemGray4).opacity(0.5), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppViewModel())
} 
