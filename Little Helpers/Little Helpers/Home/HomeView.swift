import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 170), spacing: 20)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.microApps) { app in
                            MicroAppCard(app: app)
                        }
                    }
                    
                    VStack(spacing: 4) {
                        Text("No subscriptions, just helpful tools")
                            .font(.system(.footnote, design: .rounded))
                            .fontWeight(.medium)
                        
                        Text("Tap any helper to get started")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                    .multilineTextAlignment(.center)
                }
                .padding()
            }
            .navigationTitle("Little Helpers")
            .navigationBarTitleDisplayMode(.large)
            .background(
                Color(colorScheme == .dark ? .black : .systemGray6)
                    .ignoresSafeArea()
            )
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
            if app.id == "costSplit" {
                CostSplitProjectsView()
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
                ZStack {
                    cardGradient
                    
                    // Subtle pattern overlay
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 100, height: 100)
                        .blur(radius: 20)
                        .offset(x: 80, y: -60)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(
                color: Color.accentColor.opacity(colorScheme == .dark ? 0.3 : 0.2),
                radius: 15,
                x: 0,
                y: 5
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppViewModel())
} 
