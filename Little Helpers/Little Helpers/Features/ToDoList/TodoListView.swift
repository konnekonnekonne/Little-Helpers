import SwiftUI

struct TodoListView: View {
    @ObservedObject var viewModel: TodoListViewModel
    @State private var newTaskTitle = ""
    @FocusState private var isInputFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Picker
            Picker("View", selection: $viewModel.selectedTab) {
                Text("All").tag(TodoListViewModel.Tab.all)
                Text("Flagged").tag(TodoListViewModel.Tab.flagged)
                Text("Done").tag(TodoListViewModel.Tab.done)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemGroupedBackground))
            
            List {
                if viewModel.selectedTab == .all {
                    // Quick Entry Field
                    Button(action: { isInputFocused = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                                .imageScale(.large)
                            TextField("Add a task", text: $newTaskTitle)
                                .focused($isInputFocused)
                                .onSubmit {
                                    if !newTaskTitle.isEmpty {
                                        viewModel.addItem(newTaskTitle)
                                        newTaskTitle = ""
                                        // Maintain focus after adding task
                                        isInputFocused = true
                                    }
                                }
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
                
                // Tasks
                ForEach(viewModel.filteredItems) { item in
                    TodoItemRow(item: item, viewModel: viewModel, dismissKeyboard: { isInputFocused = false })
                }
                
                if viewModel.selectedTab == .done {
                    Section {
                        Text("Completed tasks are automatically removed after 24 hours")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            // Add tap gesture to background to dismiss keyboard
            .simultaneousGesture(
                TapGesture().onEnded { _ in
                    isInputFocused = false
                }
            )
        }
        .navigationTitle("To-Do List")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Little Helpers")
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .overlay {
            if viewModel.filteredItems.isEmpty && (newTaskTitle.isEmpty || viewModel.selectedTab != .all) {
                ContentUnavailableView(
                    {
                        switch viewModel.selectedTab {
                        case .all: return "No Tasks Yet"
                        case .flagged: return "No Flagged Tasks"
                        case .done: return "No Completed Tasks"
                        }
                    }(),
                    systemImage: "checklist",
                    description: Text({
                        switch viewModel.selectedTab {
                        case .all: return "Add your first task using the field above"
                        case .flagged: return "Flag important tasks to see them here"
                        case .done: return "Completed tasks will appear here for 24 hours"
                        }
                    }())
                )
            }
        }
        // Set initial focus when the view appears
        .onAppear {
            if viewModel.selectedTab == .all {
                isInputFocused = true
            }
        }
        // Maintain focus when switching back to All tab
        .onChange(of: viewModel.selectedTab) { _, newTab in
            if newTab == .all {
                isInputFocused = true
            }
        }
    }
}

private struct TodoItemRow: View {
    let item: TodoItem
    @ObservedObject var viewModel: TodoListViewModel
    let dismissKeyboard: () -> Void
    
    var body: some View {
        HStack {
            // Completion Button
            Button(action: { 
                dismissKeyboard()
                viewModel.toggleItem(item)
            }) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            // Title
            Text(item.title)
                .strikethrough(item.isCompleted)
            
            Spacer()
            
            // Flag Button
            if !item.isCompleted {
                Button(action: { 
                    dismissKeyboard()
                    viewModel.toggleFlag(item)
                }) {
                    Image(systemName: "flag.fill")
                        .foregroundStyle(item.isFlagged ? .orange : .gray.opacity(0.3))
                }
                .buttonStyle(.plain)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            dismissKeyboard()
        }
    }
}

#Preview {
    NavigationStack {
        TodoListView(viewModel: TodoListViewModel())
    }
} 