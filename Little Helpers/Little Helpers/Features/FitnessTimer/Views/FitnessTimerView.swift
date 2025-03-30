import SwiftUI

/// Main view for the FitnessTimer helper
struct FitnessTimerView: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: FitnessTimerViewModel
    @State private var showingTemplates = false
    @State private var showingSaveTemplate = false
    @State private var showingWorkout = false
    @State private var intervalInput = "0:30"
    @State private var breakInput = "0:15"
    @State private var roundsInput = "3"
    
    private var intervalDuration: TimeInterval {
        timeInterval(from: intervalInput)
    }
    
    private var breakDuration: TimeInterval {
        timeInterval(from: breakInput)
    }
    
    private var rounds: Int {
        Int(roundsInput) ?? 3
    }
    
    // MARK: - Body
    
    var body: some View {
        List {
            // Template Selection
            Section {
                Button(action: { showingTemplates = true }) {
                    HStack {
                        Image(systemName: "rectangle.stack.fill")
                            .foregroundColor(.accentColor)
                        Text("Pick from existing templates")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Timer Configuration
            Section {
                // Interval Length
                HStack {
                    Text("Interval length")
                    Spacer()
                    TextField("0:30", text: $intervalInput)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .onChange(of: intervalInput) { _, newValue in
                            intervalInput = formatTimeInput(newValue)
                        }
                }
                
                // Break Length
                HStack {
                    Text("Break length")
                    Spacer()
                    TextField("0:15", text: $breakInput)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .onChange(of: breakInput) { _, newValue in
                            breakInput = formatTimeInput(newValue)
                        }
                }
                
                // Number of Rounds
                HStack {
                    Text("Number of rounds")
                    Spacer()
                    TextField("3", text: $roundsInput)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .onChange(of: roundsInput) { _, newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                roundsInput = filtered
                            }
                            if let value = Int(filtered) {
                                roundsInput = String(min(99, max(1, value)))
                            }
                        }
                }
            } footer: {
                Text("Format: min:sec (e.g., 1:30 for 1 minute 30 seconds)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Save Template
            Section {
                Button(action: { showingSaveTemplate = true }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down.fill")
                            .foregroundColor(.accentColor)
                        Text("Save as template")
                    }
                }
            }
            
            // Start Button
            Section {
                Button(action: {
                    viewModel.startTimer(
                        intervalDuration: intervalDuration,
                        breakDuration: breakDuration,
                        rounds: rounds
                    )
                    showingWorkout = true
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "play.fill")
                        Text("Start Timer")
                        Spacer()
                    }
                }
                .foregroundColor(.white)
                .listRowBackground(Color.accentColor)
            }
        }
        .navigationTitle("Fitness Timer")
        .sheet(isPresented: $showingTemplates) {
            TemplateListSheet(viewModel: viewModel, intervalInput: $intervalInput, breakInput: $breakInput, roundsInput: $roundsInput)
        }
        .sheet(isPresented: $showingSaveTemplate) {
            SaveTemplateSheet(
                viewModel: viewModel,
                intervalDuration: intervalDuration,
                breakDuration: breakDuration,
                rounds: rounds
            )
        }
        .fullScreenCover(isPresented: $showingWorkout) {
            WorkoutView(viewModel: viewModel)
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatTimeInput(_ input: String) -> String {
        // Remove any non-numeric characters except colon
        let filtered = input.filter { "0123456789:".contains($0) }
        
        // Handle different input cases
        if filtered.contains(":") {
            let parts = filtered.split(separator: ":")
            if parts.count == 2,
               let minutes = Int(parts[0]),
               let seconds = Int(parts[1]) {
                // Ensure seconds are within 0-59
                let adjustedSeconds = min(59, seconds)
                return "\(minutes):\(String(format: "%02d", adjustedSeconds))"
            }
        } else if let totalSeconds = Int(filtered) {
            let minutes = totalSeconds / 60
            let seconds = totalSeconds % 60
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
        
        return filtered
    }
    
    private func timeInterval(from input: String) -> TimeInterval {
        let parts = input.split(separator: ":")
        if parts.count == 2,
           let minutes = Int(parts[0]),
           let seconds = Int(parts[1]) {
            return TimeInterval(minutes * 60 + seconds)
        }
        return 0
    }
}

// MARK: - Template List Sheet

private struct TemplateListSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FitnessTimerViewModel
    @Binding var intervalInput: String
    @Binding var breakInput: String
    @Binding var roundsInput: String
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.presets.isEmpty {
                    Text("No templates saved yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.presets) { preset in
                        Button(action: {
                            // Update input fields with template values
                            intervalInput = timeString(from: preset.intervalDuration)
                            breakInput = timeString(from: preset.breakDuration)
                            roundsInput = String(preset.rounds)
                            dismiss()
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(preset.name)
                                    .font(.headline)
                                Text("\(timeString(from: preset.intervalDuration)) intervals • \(timeString(from: preset.breakDuration)) breaks • \(preset.rounds) rounds")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { viewModel.removePreset(at: $0) }
                    }
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                if !viewModel.presets.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
            }
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Save Template Sheet

private struct SaveTemplateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FitnessTimerViewModel
    
    let intervalDuration: TimeInterval
    let breakDuration: TimeInterval
    let rounds: Int
    
    @State private var name = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Template Name", text: $name)
                
                Section("Configuration") {
                    LabeledContent("Interval", value: timeString(from: intervalDuration))
                    LabeledContent("Break", value: timeString(from: breakDuration))
                    LabeledContent("Rounds", value: "\(rounds)")
                }
            }
            .navigationTitle("Save Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let preset = TimerPreset(
                            name: name,
                            intervalDuration: intervalDuration,
                            breakDuration: breakDuration,
                            rounds: rounds
                        )
                        viewModel.addPreset(preset)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Workout View

private struct WorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FitnessTimerViewModel
    @State private var showingStopConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color based on phase
                (viewModel.isBreak ? Color.green : Color.accentColor)
                    .opacity(0.1)
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Timer display
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                            .frame(width: 300, height: 300)
                        
                        Circle()
                            .trim(from: 0, to: viewModel.remainingTime / (viewModel.isBreak ? viewModel.breakDuration : viewModel.intervalDuration))
                            .stroke(
                                viewModel.isBreak ? Color.green : Color.accentColor,
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .frame(width: 300, height: 300)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: viewModel.remainingTime)
                        
                        VStack(spacing: 16) {
                            // Phase indicator
                            Text(viewModel.isBreak ? "Break" : "Interval")
                                .font(.system(.title2, design: .rounded))
                                .foregroundColor(.secondary)
                                .animation(nil, value: viewModel.isBreak)
                            
                            // Time remaining
                            Text(timeString(from: viewModel.remainingTime))
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .contentTransition(.numericText())
                            
                            // Round indicator
                            Text("Round \(viewModel.currentRound) of \(viewModel.totalRounds)")
                                .font(.system(.title3, design: .rounded))
                                .foregroundColor(.secondary)
                                .animation(nil, value: viewModel.currentRound)
                        }
                    }
                    
                    // Next up preview
                    VStack(spacing: 8) {
                        Text("Next up")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(nextPhaseText)
                            .font(.headline)
                            .animation(nil, value: nextPhaseText)
                    }
                    .opacity(viewModel.isRunning ? 1 : 0)
                    .animation(.easeInOut, value: viewModel.isRunning)
                    
                    // Controls
                    HStack(spacing: 60) {
                        // Stop button
                        Button(action: {
                            if viewModel.isRunning {
                                viewModel.pauseTimer()
                            }
                            showingStopConfirmation = true
                        }) {
                            Image(systemName: "stop.fill")
                                .font(.title)
                                .frame(width: 70, height: 70)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        
                        // Play/Pause button
                        Button(action: {
                            if viewModel.isRunning {
                                viewModel.pauseTimer()
                            } else {
                                viewModel.resumeTimer()
                            }
                        }) {
                            Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                                .font(.title)
                                .frame(width: 70, height: 70)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .confirmationDialog(
                "Stop Workout?",
                isPresented: $showingStopConfirmation,
                titleVisibility: .visible
            ) {
                Button("Stop", role: .destructive) {
                    viewModel.stopTimer()
                    dismiss()
                }
                Button("Continue", role: .cancel) {
                    viewModel.resumeTimer()
                }
            } message: {
                Text("Are you sure you want to stop the current workout?")
            }
        }
    }
    
    private var nextPhaseText: String {
        if viewModel.isBreak {
            if viewModel.currentRound < viewModel.totalRounds {
                return "Interval \(viewModel.currentRound + 1)"
            } else {
                return "Workout Complete"
            }
        } else {
            if viewModel.currentRound < viewModel.totalRounds {
                return "Break"
            } else {
                return "Workout Complete"
            }
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
} 