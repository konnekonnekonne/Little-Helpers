import SwiftUI

struct AddCountdownView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CountdownViewModel
    
    @State private var title = ""
    @State private var date = Date()
    @State private var hasCustomTime = false
    
    init(viewModel: CountdownViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Event Title", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: hasCustomTime ? [.date, .hourAndMinute] : [.date])
                    Toggle("Set specific time", isOn: $hasCustomTime)
                }
            }
            .navigationTitle("New Countdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let event = CountdownEvent(
                            title: title,
                            date: date,
                            hasCustomTime: hasCustomTime
                        )
                        viewModel.addEvent(event)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
} 