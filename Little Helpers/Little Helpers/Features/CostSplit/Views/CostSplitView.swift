import SwiftUI

struct CostSplitProjectsView: View {
    @StateObject private var viewModel = CostSplitViewModel()
    @State private var showingAddProject = false
    
    var body: some View {
        List {
            ForEach(viewModel.projects) { project in
                NavigationLink {
                    CostSplitProjectView(viewModel: viewModel, project: project)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(project.name)
                            .font(.headline)
                        Text("\(project.people.count) people · \(project.expenses.count) expenses")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Cost Split")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddProject = true }) {
                    Label("New Project", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddProject) {
            NavigationStack {
                AddProjectSheet(viewModel: viewModel, isPresented: $showingAddProject)
            }
        }
    }
}

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
                            
                            Button("Add Expense") {
                                showingAddExpense = true
                            }
                            .buttonStyle(.borderedProminent)
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
                        
                        Button("Add Person") {
                            showingAddPerson = true
                        }
                    } header: {
                        Text("People")
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

struct ExpenseRow: View {
    let expense: Expense
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(expense.title)
                    .font(.headline)
                Spacer()
                Text(String(format: "€%.2f", expense.amount))
                    .font(.headline)
            }
            
            HStack {
                Text("Paid by \(expense.paidBy.name)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(dateFormatter.string(from: expense.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SettlementRow: View {
    let settlement: Settlement
    
    var body: some View {
        HStack {
            Text(settlement.fromPerson.name)
            Image(systemName: "arrow.right")
                .foregroundColor(.secondary)
            Text(settlement.toPerson.name)
            Spacer()
            Text(String(format: "€%.2f", settlement.amount))
                .bold()
        }
    }
}

struct AddPersonSheet: View {
    @ObservedObject var viewModel: CostSplitViewModel
    @Binding var isPresented: Bool
    @State private var name = ""
    let project: Project
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
        }
        .navigationTitle("Add Person")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    isPresented = false
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    if !name.isEmpty {
                        viewModel.addPerson(name: name, to: project)
                        isPresented = false
                    }
                }
                .disabled(name.isEmpty)
            }
        }
    }
}

struct AddExpenseSheet: View {
    @ObservedObject var viewModel: CostSplitViewModel
    @Binding var isPresented: Bool
    let project: Project
    
    @State private var title = ""
    @State private var amount = ""
    @State private var paidBy: Person?
    @State private var splitAmongAll = true
    @State private var participants: Set<Person> = []
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
            
            TextField("0,00", text: $amount)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.leading)
                .onChange(of: amount) { _, newValue in
                    let filtered = newValue.filter { "0123456789,".contains($0) }
                    if filtered != newValue {
                        amount = filtered
                    }
                }
            
            Picker("Paid by", selection: $paidBy) {
                Text("Select a person").tag(nil as Person?)
                ForEach(project.people) { person in
                    Text(person.name).tag(person as Person?)
                }
            }
            
            Section("Split among") {
                Toggle("Split among all", isOn: $splitAmongAll)
                    .onChange(of: splitAmongAll) { _, newValue in
                        if newValue {
                            participants = Set(project.people)
                        }
                    }
                
                if !splitAmongAll {
                    ForEach(project.people) { person in
                        Toggle(person.name, isOn: Binding(
                            get: { participants.contains(person) },
                            set: { isSelected in
                                if isSelected {
                                    participants.insert(person)
                                } else {
                                    participants.remove(person)
                                }
                                if participants.count == project.people.count {
                                    splitAmongAll = true
                                }
                            }
                        ))
                    }
                }
            }
        }
        .navigationTitle("Add Expense")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    isPresented = false
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    if let amount = Double(amount.replacingOccurrences(of: ",", with: ".")),
                       let paidBy = paidBy,
                       !title.isEmpty,
                       !participants.isEmpty {
                        viewModel.addExpense(
                            title: title,
                            amount: amount,
                            paidBy: paidBy,
                            participants: Array(participants),
                            date: Date(),
                            to: project
                        )
                        isPresented = false
                    }
                }
                .disabled(
                    title.isEmpty ||
                    amount.isEmpty ||
                    paidBy == nil ||
                    participants.isEmpty
                )
            }
        }
        .onAppear {
            // Initialize split among all people
            participants = Set(project.people)
        }
    }
}

struct EditExpenseSheet: View {
    @ObservedObject var viewModel: CostSplitViewModel
    @Binding var isPresented: Bool
    let expense: Expense
    let project: Project
    
    @State private var title: String
    @State private var amount: String
    @State private var paidBy: Person?
    @State private var splitAmongAll: Bool
    @State private var participants: Set<Person>
    
    init(viewModel: CostSplitViewModel, isPresented: Binding<Bool>, expense: Expense, project: Project) {
        self.viewModel = viewModel
        self._isPresented = isPresented
        self.expense = expense
        self.project = project
        
        _title = State(initialValue: expense.title)
        _amount = State(initialValue: String(format: "%.2f", expense.amount).replacingOccurrences(of: ".", with: ","))
        _paidBy = State(initialValue: expense.paidBy)
        _participants = State(initialValue: Set(expense.participants))
        _splitAmongAll = State(initialValue: Set(expense.participants) == Set(project.people))
    }
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
            
            TextField("0,00", text: $amount)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.leading)
                .onChange(of: amount) { _, newValue in
                    let filtered = newValue.filter { "0123456789,".contains($0) }
                    if filtered != newValue {
                        amount = filtered
                    }
                }
            
            Picker("Paid by", selection: $paidBy) {
                Text("Select a person").tag(nil as Person?)
                ForEach(project.people) { person in
                    Text(person.name).tag(person as Person?)
                }
            }
            
            Section("Split among") {
                Toggle("Split among all", isOn: $splitAmongAll)
                    .onChange(of: splitAmongAll) { _, newValue in
                        if newValue {
                            participants = Set(project.people)
                        }
                    }
                
                if !splitAmongAll {
                    ForEach(project.people) { person in
                        Toggle(person.name, isOn: Binding(
                            get: { participants.contains(person) },
                            set: { isSelected in
                                if isSelected {
                                    participants.insert(person)
                                } else {
                                    participants.remove(person)
                                }
                                if participants.count == project.people.count {
                                    splitAmongAll = true
                                }
                            }
                        ))
                    }
                }
            }
        }
        .navigationTitle("Edit Expense")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    isPresented = false
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if let amount = Double(amount.replacingOccurrences(of: ",", with: ".")),
                       let paidBy = paidBy,
                       !title.isEmpty,
                       !participants.isEmpty {
                        viewModel.updateExpense(
                            expense,
                            title: title,
                            amount: amount,
                            paidBy: paidBy,
                            participants: Array(participants),
                            date: expense.date,
                            in: project
                        )
                        isPresented = false
                    }
                }
                .disabled(
                    title.isEmpty ||
                    amount.isEmpty ||
                    paidBy == nil ||
                    participants.isEmpty
                )
            }
        }
    }
}

struct AddProjectSheet: View {
    @ObservedObject var viewModel: CostSplitViewModel
    @Binding var isPresented: Bool
    @State private var name = ""
    
    var body: some View {
        Form {
            TextField("Project Name", text: $name)
        }
        .navigationTitle("New Project")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    isPresented = false
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Create") {
                    if !name.isEmpty {
                        viewModel.createProject(name: name)
                        isPresented = false
                    }
                }
                .disabled(name.isEmpty)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CostSplitProjectsView()
    }
} 