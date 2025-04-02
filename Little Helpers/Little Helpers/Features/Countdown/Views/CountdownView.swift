import SwiftUI

struct CountdownView: View {
    @StateObject private var viewModel = CountdownViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.events.isEmpty {
                    ContentUnavailableView(
                        "No Countdowns",
                        systemImage: "timer",
                        description: Text("Add your first countdown to get started")
                    )
                    .padding(.top, 20)
                } else {
                    ForEach(sortedEvents) { event in
                        SwipeableCountdownCard(
                            event: event,
                            currentTime: viewModel.currentTime,
                            onDelete: { viewModel.deleteEvent(event) }
                        )
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Countdown")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.showingAddEvent = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddEvent) {
            AddCountdownView(viewModel: viewModel)
        }
        .animation(.smooth, value: viewModel.events)
    }
    
    private var sortedEvents: [CountdownEvent] {
        let active = viewModel.events.filter { !$0.isCompleted }
            .sorted { event1, event2 in
                let time1 = event1.timeComponents(currentDate: viewModel.currentTime)
                let time2 = event2.timeComponents(currentDate: viewModel.currentTime)
                return time1.totalSeconds < time2.totalSeconds
            }
        let completed = viewModel.events.filter { $0.isCompleted }
        return active + completed
    }
}

struct SwipeableCountdownCard: View {
    let event: CountdownEvent
    let currentTime: Date
    let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isSwiped: Bool = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete button
            deleteButton
            
            // Card content
            CountdownCard(event: event, currentTime: currentTime)
                .background(Color(.systemBackground))
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged(onDragChanged)
                        .onEnded(onDragEnded)
                )
        }
        .padding(.top, 20)
        .clipped()
    }
    
    private var deleteButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                offset = 0
                isSwiped = false
                onDelete()
            }
        }) {
            Image(systemName: "trash")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 60, height: .infinity)
                .background(.red)
        }
    }
    
    private func onDragChanged(_ value: DragGesture.Value) {
        let dragAmount = value.translation.width
        
        // Only allow left swipe
        if dragAmount <= 0 {
            // Add resistance when dragging
            offset = dragAmount / 2
        }
    }
    
    private func onDragEnded(_ value: DragGesture.Value) {
        withAnimation(.spring(response: 0.3)) {
            let dragAmount = value.translation.width
            let dragThreshold: CGFloat = -50
            
            if dragAmount < dragThreshold {
                offset = -60
                isSwiped = true
            } else {
                offset = 0
                isSwiped = false
            }
        }
    }
}

struct CountdownCard: View {
    let event: CountdownEvent
    let currentTime: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title with optional checkmark
            HStack(spacing: 4) {
                if event.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
                }
                Text(event.title)
                    .font(.headline)
                    .foregroundStyle(event.isCompleted ? .white : .primary)
            }
            
            if event.isCompleted {
                // Show "Time is up" message
                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.white)
                        Text("Time is up")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                        Image(systemName: "sparkles")
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                }
            } else {
                VStack(spacing: 4) {
                    // Time numbers
                    let time = event.timeComponents(currentDate: currentTime)
                    let showSeconds = event.shouldShowSeconds(currentDate: currentTime)
                    
                    if showSeconds {
                        // Show hours:minutes:seconds
                        HStack(spacing: 0) {
                            Text("\(String(format: "%02d", time.hours))")
                                .frame(maxWidth: .infinity)
                                .font(.system(.title, design: .monospaced))
                                .fontWeight(.medium)
                                .foregroundStyle(Color.accentColor)
                            Text(":")
                                .font(.system(.title, design: .monospaced))
                                .fontWeight(.medium)
                                .foregroundStyle(Color.accentColor)
                            Text("\(String(format: "%02d", time.minutes))")
                                .frame(maxWidth: .infinity)
                                .font(.system(.title, design: .monospaced))
                                .fontWeight(.medium)
                                .foregroundStyle(Color.accentColor)
                            Text(":")
                                .font(.system(.title, design: .monospaced))
                                .fontWeight(.medium)
                                .foregroundStyle(Color.accentColor)
                            Text("\(String(format: "%02d", time.seconds))")
                                .frame(maxWidth: .infinity)
                                .font(.system(.title, design: .monospaced))
                                .fontWeight(.medium)
                                .foregroundStyle(Color.accentColor)
                        }
                    } else {
                        // Show days:hours:minutes
                        HStack(spacing: 0) {
                            Text("\(String(format: "%02d", time.days))")
                                .frame(maxWidth: .infinity)
                                .font(.system(.title, design: .monospaced))
                                .fontWeight(.medium)
                                .foregroundStyle(Color.accentColor)
                            Text(":")
                                .font(.system(.title, design: .monospaced))
                                .fontWeight(.medium)
                                .foregroundStyle(Color.accentColor)
                            Text("\(String(format: "%02d", time.hours))")
                                .frame(maxWidth: .infinity)
                                .font(.system(.title, design: .monospaced))
                                .fontWeight(.medium)
                                .foregroundStyle(Color.accentColor)
                            Text(":")
                                .font(.system(.title, design: .monospaced))
                                .fontWeight(.medium)
                                .foregroundStyle(Color.accentColor)
                            Text("\(String(format: "%02d", time.minutes))")
                                .frame(maxWidth: .infinity)
                                .font(.system(.title, design: .monospaced))
                                .fontWeight(.medium)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    
                    // Labels
                    HStack(spacing: 0) {
                        if showSeconds {
                            Text("Hrs")
                                .frame(maxWidth: .infinity)
                            Text(" ")
                                .frame(width: 10)
                            Text("Min")
                                .frame(maxWidth: .infinity)
                            Text(" ")
                                .frame(width: 10)
                            Text("Sec")
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Days")
                                .frame(maxWidth: .infinity)
                            Text(" ")
                                .frame(width: 10)
                            Text("Hrs")
                                .frame(maxWidth: .infinity)
                            Text(" ")
                                .frame(width: 10)
                            Text("Min")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(event.isCompleted ? Color.green : Color(.systemBackground))
                .shadow(color: Color(.systemGray4).opacity(0.5), radius: 4)
        )
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        CountdownView()
    }
} 