import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = AppViewModel()
    
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 170), spacing: 20)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.microApps) { app in
                            MicroAppCard(app: app)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Little Helpers")
        }
    }
}

struct MicroAppCard: View {
    let app: MicroApp
    @Environment(\.colorScheme) private var colorScheme
    
    private var cardGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.accentColor.opacity(0.8),
                Color.accentColor
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        NavigationLink {
            switch app.id {
            case "costSplit":
                CostSplitView()
            case "fitnessTimer":
                FitnessTimerCoordinator().makeRootView()
            case "toDoList":
                EmptyView() // TODO: Implement ToDoList
            default:
                EmptyView()
            }
        } label: {
            VStack(spacing: 16) {
                // Icon centered at the top
                Image(systemName: app.icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                    )
                
                // Centered text content
                VStack(spacing: 8) {
                    Text(app.name)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(app.description)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppViewModel())
} 
