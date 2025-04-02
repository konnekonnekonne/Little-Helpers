import SwiftUI

struct CountdownView: View {
    @StateObject private var viewModel = CountdownViewModel()
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        List {
            if viewModel.events.isEmpty {
                ContentUnavailableView(
                    "No Countdowns",
                    systemImage: "timer",
                    description: Text("Add your first countdown to get started")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(viewModel.events) { event in
                    CountdownCard(event: event, currentTime: viewModel.currentTime)
                }
                .onMove(perform: viewModel.moveEvent)
                .onDelete(perform: viewModel.deleteEvent)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Countdown")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.showingAddEvent = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            if !viewModel.events.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddEvent) {
            AddCountdownView(viewModel: viewModel)
        }
        .onChange(of: viewModel.showingAddEvent) { _, isShowing in
            if !isShowing {
                editMode?.wrappedValue = .inactive
            }
        }
        .animation(.smooth, value: viewModel.events)
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