import SwiftUI

struct CostSplitProjectView: View {
    @ObservedObject var viewModel: CostSplitViewModel
    private let projectId: UUID
    @State private var showingAddPerson = false
    @State private var showingAddExpense = false
    @State private var showingEditExpense = false
    @State private var showingDeleteConfirmation = false
    @State private var expenseToEdit: Expense?
    @Environment(\.dismiss) private var dismiss
    
    private var project: Project? {
        viewModel.getProject(id: projectId)
    }
    
    init(viewModel: CostSplitViewModel, project: Project) {
        self.viewModel = viewModel
        self.projectId = project.id
    }
    
    var body: some View {
        Group {
            if let project = project {
                List {
                    // Expenses Section
                    if !project.people.isEmpty {
                        Section("Expenses") {
                            ForEach(project.expenses) { expense in
                                ExpenseRow(expense: expense)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            viewModel.removeExpense(expense, from: project)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        
                                        Button {
                                            expenseToEdit = expense
                                            showingEditExpense = true
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.orange)
                                    }
                            }
                            
                            Button(action: { showingAddExpense = true }) {
                                Text("Add Expense")
                            }
                            .foregroundColor(.accentColor)
                        }
                    }
                    
                    // Settlements Section
                    if !viewModel.getSettlements(for: project).isEmpty {
                        Section("Settlements") {
                            ForEach(viewModel.getSettlements(for: project)) { settlement in
                                SettlementRow(settlement: settlement)
                            }
                        }
                    }
                    
                    // People Section
                    Section {
                        ForEach(project.people) { person in
                            Text(person.name)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.removePerson(project.people[index], from: project)
                            }
                        }
                        
                        Button("Add to group") {
                            showingAddPerson = true
                        }
                    } header: {
                        Text("Your group")
                    } footer: {
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Text("Delete Project")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .padding(.top)
                    }
                }
                .navigationTitle(project.name)
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showingAddPerson) {
                    NavigationStack {
                        AddPersonSheet(viewModel: viewModel, isPresented: $showingAddPerson, project: project)
                    }
                }
                .sheet(isPresented: $showingAddExpense) {
                    NavigationStack {
                        AddExpenseSheet(viewModel: viewModel, isPresented: $showingAddExpense, project: project)
                    }
                }
                .sheet(isPresented: $showingEditExpense) {
                    if let expense = expenseToEdit {
                        NavigationStack {
                            EditExpenseSheet(viewModel: viewModel, isPresented: $showingEditExpense, expense: expense, project: project)
                        }
                    }
                }
                .confirmationDialog(
                    "Delete Project?",
                    isPresented: $showingDeleteConfirmation
                ) {
                    Button("Delete \(project.name)", role: .destructive) {
                        viewModel.removeProject(project)
                        dismiss()
                    }
                } message: {
                    Text("Are you sure you want to delete '\(project.name)'? This action cannot be undone.")
                }
            } else {
                Text("Project not found")
                    .navigationTitle("Error")
            }
        }
    }
} 