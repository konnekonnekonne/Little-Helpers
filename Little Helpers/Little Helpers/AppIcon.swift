import SwiftUI

struct AppIcon: View {
    let colors: [Color] = [
        .blue,
        .purple,
        .pink,
        .orange,
        .yellow,
        .green,
        .mint,
        .teal,
        .indigo
    ]
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 200)
                .fill(Color(.systemBackground))
            
            // Grid of dots
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 60), count: 3), spacing: 60) {
                ForEach(0..<9) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    colors[index].opacity(0.8),
                                    colors[index]
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: colors[index].opacity(0.3), radius: 10, x: 0, y: 5)
                }
            }
            .padding(100)
        }
        .frame(width: 1024, height: 1024)
        .background(Color(.systemBackground))
    }
}

#Preview {
    AppIcon()
} 